"""
iMorph Reloader - 卸载旧 DLL 后重新注入
解决 /reload 或小退后 iMorph.dll 内部 lua_State* 指针失效的问题
双击运行即可
"""
import ctypes
import ctypes.wintypes
import os
import sys
import time
import subprocess

# Windows API
kernel32 = ctypes.windll.kernel32
PROCESS_ALL_ACCESS = (0x000F0000 | 0x00100000 | 0xFFF)
INFINITE = 0xFFFFFFFF

# WoW 进程名
WOW_EXE = "Wow.exe"

def find_wow_process():
    """查找 Wow.exe 进程，返回进程 ID"""
    entry = ctypes.wintypes.DWORD()
    snapshot = kernel32.CreateToolhelp32Snapshot(0x00000002, 0)  # TH32CS_SNAPPROCESS
    if snapshot == -1:
        return None

    class ProcessEntry32(ctypes.Structure):
        _fields_ = [
            ("dwSize", ctypes.wintypes.DWORD),
            ("cntUsage", ctypes.wintypes.DWORD),
            ("th32ProcessID", ctypes.wintypes.DWORD),
            ("th32DefaultHeapID", ctypes.POINTER(ctypes.c_ulong)),
            ("th32ModuleID", ctypes.wintypes.DWORD),
            ("cntThreads", ctypes.wintypes.DWORD),
            ("th32ParentProcessID", ctypes.wintypes.DWORD),
            ("pcPriClassBase", ctypes.c_long),
            ("dwFlags", ctypes.wintypes.DWORD),
            ("szExeFile", ctypes.c_char * 260),
        ]

    pe = ProcessEntry32()
    pe.dwSize = ctypes.sizeof(ProcessEntry32)

    pid = None
    if kernel32.Process32First(snapshot, ctypes.byref(pe)):
        while True:
            if pe.szExeFile.decode('utf-8', errors='ignore').lower() == WOW_EXE.lower():
                pid = pe.th32ProcessID
                break
            if not kernel32.Process32Next(snapshot, ctypes.byref(pe)):
                break

    kernel32.CloseHandle(snapshot)
    return pid

def get_remote_module_handle(hProcess, module_name):
    """在远程进程中查找模块，返回基址（远程指针值）"""
    hModules = (ctypes.c_void_p * 1024)()
    cbNeeded = ctypes.wintypes.DWORD()

    if not kernel32.EnumProcessModules(hProcess, hModules, ctypes.sizeof(hModules), ctypes.byref(cbNeeded)):
        return None

    count = cbNeeded.value // ctypes.sizeof(ctypes.c_void_p)
    target = module_name.lower().encode('utf-8')

    for i in range(count):
        modFileName = ctypes.create_unicode_buffer(260)
        if kernel32.GetModuleFileNameW(hProcess, hModules[i], modFileName, 260):
            if target in modFileName.value.lower():
                return hModules[i]

    return None

def remote_free_library(hProcess, module_handle):
    """在远程进程中调用 FreeLibrary 卸载指定模块"""
    # 获取 FreeLibrary 的地址
    freeLibAddr = kernel32.GetProcAddress(kernel32.GetModuleHandleW("kernel32.dll"), "FreeLibrary")
    if not freeLibAddr:
        return False

    # 在远程进程中写入模块句柄作为参数
    paramAddr = kernel32.VirtualAllocEx(hProcess, None, ctypes.sizeof(ctypes.c_void_p), 0x1000 | 0x2000, 0x04)
    if not paramAddr:
        return False

    handle_val = ctypes.c_void_p(module_handle)
    written = ctypes.c_size_t(0)
    kernel32.WriteProcessMemory(hProcess, paramAddr, ctypes.byref(handle_val), ctypes.sizeof(ctypes.c_void_p), ctypes.byref(written))

    # 创建远程线程调用 FreeLibrary(module_handle)
    threadId = ctypes.wintypes.DWORD(0)
    hThread = kernel32.CreateRemoteThread(hProcess, None, 0, freeLibAddr, paramAddr, 0, ctypes.byref(threadId))
    if not hThread:
        kernel32.VirtualFreeEx(hProcess, paramAddr, 0, 0x8000)
        return False

    # 等待卸载完成
    kernel32.WaitForSingleObject(hThread, 5000)
    kernel32.CloseHandle(hThread)
    kernel32.VirtualFreeEx(hProcess, paramAddr, 0, 0x8000)
    return True

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    exe_path = os.path.join(script_dir, "RuniMorph.exe")

    if not os.path.exists(exe_path):
        ctypes.windll.user32.MessageBoxW(0, f"找不到 RuniMorph.exe\n{exe_path}", "iMorph Reloader", 0x10)
        return

    # 查找 Wow.exe
    pid = find_wow_process()
    if pid is None:
        ctypes.windll.user32.MessageBoxW(0, "未找到 Wow.exe 进程\n请先启动魔兽世界", "iMorph Reloader", 0x10)
        return

    # 打开进程
    hProcess = kernel32.OpenProcess(PROCESS_ALL_ACCESS, False, pid)
    if not hProcess:
        ctypes.windll.user32.MessageBoxW(0, f"无法打开 Wow.exe 进程 (PID: {pid})\n请以管理员身份运行", "iMorph Reloader", 0x10)
        return

    # 检查 iMorph.dll 是否已加载
    modHandle = get_remote_module_handle(hProcess, "iMorph.dll")

    if modHandle:
        print(f"检测到 iMorph.dll 已加载 (基址: 0x{modHandle:X})")
        print("正在卸载旧 DLL...")

        if remote_free_library(hProcess, modHandle):
            print("旧 DLL 已卸载，等待清理...")
            time.sleep(1)
        else:
            print("卸载失败，尝试继续注入...")
    else:
        print("iMorph.dll 未加载，直接注入...")

    kernel32.CloseHandle(hProcess)

    # 运行 RuniMorph.exe
    print("启动 RuniMorph.exe...")
    subprocess.Popen([exe_path], cwd=script_dir)
    print("完成！")

if __name__ == "__main__":
    main()
