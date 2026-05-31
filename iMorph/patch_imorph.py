"""
iMorph.dll Patch Tool - /reload 后 lua_State* 过时修复
自动定位缓存地址，游戏更新后直接运行即可。

用法:
  python patch_imorph.py            打补丁
  python patch_imorph.py --verify   检查状态
  python patch_imorph.py --restore  还原原始DLL
"""

import struct
import shutil
import sys
from pathlib import Path

DLL_PATH     = Path(__file__).parent / "iMorph.dll"
BACKUP_PATH  = Path(__file__).parent / "iMorph.dll.bak"
TEXT_RVA     = 0x1000
TEXT_OFF     = 0x400
DATA_RVA_MIN = 0x3E000
DATA_RVA_MAX = 0x4B000
SZ           = 7  # 每条指令 7 字节

PATCHED_READ  = bytes([0x48, 0x89, 0xC8, 0x90, 0x90, 0x90, 0x90])
PATCHED_STORE = bytes([0x90] * SZ)

# ============================================================

def scan_rip_refs(data, opcode_mask, is_store=False):
    """
    扫描所有 rip-relative 读写并统计目标地址。
    opcode_mask: (byte_0, byte_1, modrm_mask, modrm_val)
    例如 mov reg,[rip+disp] = (0x48, 0x8B, 0xC7, 0x05)
    返回 {target_rva: [(instr_rva, reg)]}
    """
    refs = {}
    for i in range(TEXT_OFF, len(data) - SZ + 1):
        instr_rva = i - TEXT_OFF + TEXT_RVA
        b0, b1 = data[i], data[i+1]
        if b0 != opcode_mask[0] or b1 != opcode_mask[1]:
            continue
        if (data[i+2] & opcode_mask[2]) != opcode_mask[3]:
            continue
        disp = struct.unpack('<i', data[i+3:i+7])[0]
        target = instr_rva + SZ + disp
        if DATA_RVA_MIN <= target <= DATA_RVA_MAX:
            reg = (data[i+2] >> 3) & 7
            refs.setdefault(target, []).append((instr_rva, reg))
    return refs


def find_original_cache(data):
    """在原始 DLL 中找到被同时读写的缓存地址"""
    reads  = scan_rip_refs(data, (0x48, 0x8B, 0xC7, 0x05))   # mov reg, [rip+disp]
    stores = scan_rip_refs(data, (0x48, 0x89, 0xC7, 0x05), True)  # mov [rip+disp], reg
    # 改成精确匹配 rcx: mov [rip+disp], rcx = 48 89 0D
    stores_rcx = {}
    for i in range(TEXT_OFF, len(data) - SZ + 1):
        if data[i] == 0x48 and data[i+1] == 0x89 and data[i+2] == 0x0D:
            disp = struct.unpack('<i', data[i+3:i+7])[0]
            target = (i - TEXT_OFF + TEXT_RVA) + SZ + disp
            if DATA_RVA_MIN <= target <= DATA_RVA_MAX:
                stores_rcx.setdefault(target, []).append((i - TEXT_OFF + TEXT_RVA, None))

    candidates = []
    for tgt in set(list(reads.keys()) + list(stores_rcx.keys())):
        r = reads.get(tgt, [])
        s = stores_rcx.get(tgt, [])
        if r and s:
            candidates.append((tgt, len(r) + len(s), len(r), len(s)))
    candidates.sort(key=lambda x: -x[1])
    return candidates, reads, stores_rcx


def find_patched_regions(data):
    """在已补丁 DLL 中找到被修改过的指令位置"""
    patched_r = []
    patched_s = []
    for i in range(TEXT_OFF, len(data) - SZ + 1):
        chunk = bytes(data[i:i+SZ])
        rva = i - TEXT_OFF + TEXT_RVA
        if chunk == PATCHED_READ:
            patched_r.append(rva)
        elif chunk == PATCHED_STORE:
            patched_s.append(rva)
    return patched_r, patched_s


# ============================================================

def do_verify():
    if not DLL_PATH.exists():
        print(f"ERROR: {DLL_PATH} not found"); sys.exit(1)
    with open(DLL_PATH, 'rb') as f:
        data = bytearray(f.read())

    # 1. 检查是否已有补丁
    patched_r, patched_s = find_patched_regions(data)
    if patched_r or patched_s:
        print(f"[PATCHED] 已打补丁: {len(patched_r)} 读 + {len(patched_s)} 写")
        for rva in patched_r:
            print(f"  READ  0x{rva:08X}")
        for rva in patched_s:
            print(f"  STORE 0x{rva:08X}")
        return True

    # 2. 检查原始 DLL 状态
    candidates, reads, stores = find_original_cache(data)
    if not candidates:
        print("[UNKNOWN] 未找到匹配的缓存地址模式，DLL 结构可能已变化")
        return False

    best = candidates[0]
    print(f"原始 DLL - 缓存地址 RVA 0x{best[0]:08X} ({best[2]}读 + {best[3]}写 = {best[1]}次)")
    for rva, _ in reads.get(best[0], []):
        print(f"  READ  0x{rva:08X}")
    for rva, _ in stores.get(best[0], []):
        print(f"  STORE 0x{rva:08X}")
    print("\n  -> 状态: 未打补丁")
    return False


def do_patch():
    if not DLL_PATH.exists():
        print(f"ERROR: {DLL_PATH} not found"); sys.exit(1)

    with open(DLL_PATH, 'rb') as f:
        data = bytearray(f.read())

    # 先检查是否已打补丁
    pr, ps = find_patched_regions(data)
    if pr or ps:
        print(f"已打补丁 ({len(pr)}读 + {len(ps)}写)，无需重复操作。")
        print("强制重打: python patch_imorph.py --restore && python patch_imorph.py")
        return

    # 备份
    if not BACKUP_PATH.exists():
        shutil.copy2(DLL_PATH, BACKUP_PATH)
        print(f"备份: {BACKUP_PATH.name}")

    # 分析
    candidates, reads, stores = find_original_cache(data)
    if not candidates:
        print("ERROR: 无法识别 DLL 结构"); return

    cache_rva = candidates[0][0]
    target_r = reads.get(cache_rva, [])
    target_s = stores.get(cache_rva, [])

    print(f"缓存 RVA 0x{cache_rva:08X}: {len(target_r)}读 + {len(target_s)}写\n")

    for rva, _ in target_r:
        o = rva - TEXT_RVA + TEXT_OFF
        old = bytes(data[o:o+SZ])
        data[o:o+SZ] = PATCHED_READ
        print(f"  R 0x{rva:08X}: {old.hex()} -> mov rax, rcx")

    for rva, _ in target_s:
        o = rva - TEXT_RVA + TEXT_OFF
        old = bytes(data[o:o+SZ])
        data[o:o+SZ] = PATCHED_STORE
        print(f"  W 0x{rva:08X}: {old.hex()} -> NOP")

    with open(DLL_PATH, 'wb') as f:
        f.write(data)

    print(f"\nDONE: {DLL_PATH.name}")
    print("完全重启 WoW 客户端后生效!")


def do_restore():
    if not BACKUP_PATH.exists():
        print(f"ERROR: {BACKUP_PATH.name} 不存在"); sys.exit(1)
    shutil.copy2(BACKUP_PATH, DLL_PATH)
    print(f"已还原: {DLL_PATH.name}")


def main():
    print("=" * 50)
    print("iMorph.dll - lua_State* 修复")
    print("=" * 50)

    if "--restore" in sys.argv:
        do_restore()
    elif "--verify" in sys.argv:
        do_verify()
    else:
        do_verify()
        print()
        do_patch()
        print()
        do_verify()


if __name__ == "__main__":
    main()
