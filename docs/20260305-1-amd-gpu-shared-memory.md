# Research: Disabling Shared GPU Memory / VRAM Offloading on Windows 11 for AMD Radeon 7900 XT

**Date:** March 5, 2026
**Target Hardware:** AMD Radeon 7900 XT (20GB VRAM)
**Issue:** Windows offloading VRAM to system RAM, affecting llama server performance. `--mlock` flag not being respected.

---

## Executive Summary

Windows 11 does not provide a direct method to disable shared GPU memory or prevent VRAM-to-RAM offloading for discrete GPUs like the AMD Radeon 7900 XT. The shared memory allocation (up to 50% of system RAM) is automatically managed by the Windows display driver model (WDDM) and cannot be directly controlled through registry keys or settings.

However, several approaches may help mitigate the issue:

1. **Disable Hardware Accelerated GPU Scheduling (HAGS)** - May reduce aggressive memory management
2. **Disable ULPS (Ultra Low Power State)** - Prevents GPU from entering low-power states that trigger memory offloading
3. **Enable "Lock Pages in Memory" privilege** - Required for `--mlock` to function on Windows
4. **Adjust TDR (Timeout Detection and Recovery) settings** - Prevents driver resets during long GPU operations
5. **AMD Adrenalin settings** - Smart Access Memory and power management options
6. **Keep GPU active** - Prevent idle-state memory offloading (similar to Linux `amdgpu.runpm=0`)

**Key Finding:** The `--mlock` flag in llama.cpp requires the Windows "Lock Pages in Memory" privilege (`SeLockMemoryPrivilege`) to function. Without this privilege, memory locking fails silently.

---

## Key Findings

### 1. Hardware Accelerated GPU Scheduling (HAGS)

**Confidence:** HIGH

**Evidence:**
- [HowToGeek - Enable Hardware-Accelerated GPU Scheduling](https://www.howtogeek.com/756935/how-to-enable-hardware-accelerated-gpu-scheduling-in-windows-11/)
- [Prajwal Desai - Hardware Accelerated GPU Scheduling](https://www.prajwaldesai.com/hardware-accelerated-gpu-scheduling/)

**Registry Configuration:**
```
Path: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers
Value: HwSchMode (DWORD 32-bit)
  - 1 = Disable HAGS
  - 2 = Enable HAGS (default on Windows 11 fresh installs)
```

**GUI Method:**
1. Settings → System → Display → Graphics Settings
2. Toggle "Hardware-accelerated GPU scheduling" Off
3. Restart required

**Impact on Memory Management:**
- HAGS offloads GPU scheduling to a dedicated GPU-based scheduling processor
- May cause more aggressive memory management and VRAM offloading when GPU is idle
- **Recommendation:** Try disabling HAGS (set `HwSchMode=1`) to see if it reduces VRAM offloading

**Risks/Side Effects:**
- May slightly increase latency in some applications
- Requires system restart to apply changes
- Some games/applications may perform better with HAGS enabled

---

### 2. ULPS (Ultra Low Power State)

**Confidence:** HIGH

**Evidence:**
- [VicLovan - ULPS Slow Startup Fix](https://www.viclovan.com/ulps-slow-startup)
- [Tom's Hardware - Disable ULPS on AMD Crossfire](https://forums.tomshardware.com/threads/how-to-disable-ulps-on-amd-crossfire-setups.1586693/)
- [Reddit - Disable ULPS on Navi 33 GPUs](https://www.reddit.com/r/AMDHelp/comments/1bsye1f/how-to_disable_ulps_on_navi_33_gpus/)

**Registry Configuration:**
```
Paths (may exist in multiple locations):
  - HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001
  - HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\amdkmdag
  - HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001
  - HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\amdkmdag

Value: EnableULPS (DWORD 32-bit)
  - 0 = Disable ULPS (recommended)
  - 1 = Enable ULPS (default)
```

**How to Modify:**
1. Open Registry Editor (Win+R, type `regedit`)
2. Search for `EnableULPS`
3. Change value from `1` to `0`
4. Reboot system

**Impact on Memory Management:**
- ULPS causes GPU to enter ultra-low power state when idle
- This triggers VRAM contents to be offloaded to system RAM
- Disabling ULPS keeps GPU in active state, preventing memory offloading
- **Similar to Linux `amdgpu.runpm=0`** which prevents runtime power management

**Risks/Side Effects:**
- Slightly higher power consumption when GPU is idle
- May reduce battery life on laptops (not applicable to desktop 7900 XT)
- Generally safe to disable on desktop systems

---

### 3. Lock Pages in Memory Privilege (Required for --mlock)

**Confidence:** HIGH

**Evidence:**
- [Microsoft - Lock Pages in Memory](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/security-policy-settings/lock-pages-in-memory)
- [llama.cpp Discussion #638](https://github.com/ggml-org/llama.cpp/discussions/638)
- [llama-cpp-python Issue #254](https://github.com/abetlen/llama-cpp-python/issues/254)

**What is SeLockMemoryPrivilege:**
- Windows security policy that allows processes to keep data in physical memory
- Prevents OS from paging locked data to virtual memory on disk
- **Required for `--mlock` flag to function in llama.cpp on Windows**

**How to Enable:**

**Method 1 - Local Security Policy (secpol.msc):**
1. Press Win+R, type `secpol.msc`, press Enter
2. Navigate to: Local Policies → User Rights Assignment
3. Find "Lock pages in memory"
4. Add your user account or the account running llama-server
5. Log off and log back in (or restart)

**Method 2 - Group Policy (gpedit.msc):**
1. Press Win+R, type `gpedit.msc`, press Enter
2. Navigate to: Computer Configuration → Windows Settings → Security Settings → Local Policies → User Rights Assignment
3. Find "Lock pages in memory"
4. Add your user account
5. Log off and log back in

**Method 3 - Command Line (requires Admin):**
```powershell
# Add current user to Lock Pages in Memory privilege
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
secedit /export /cfg C:\secpol.cfg
# Edit C:\secpol.cfg to add user to SeLockMemoryPrivilege
secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas USER_RIGHTS
```

**Verification:**
```powershell
# Check if privilege is assigned
whoami /priv | findstr SeLockMemoryPrivilege
```

**Risks/Side Effects:**
- Can cause denial-of-service if misused (process can exhaust physical RAM)
- Only grant to trusted applications
- May reduce system stability under memory pressure
- Microsoft recommends not assigning this privilege unless specifically required

---

### 4. TDR (Timeout Detection and Recovery) Settings

**Confidence:** HIGH

**Evidence:**
- [Puget Systems - Working Around TDR](https://www.pugetsystems.com/labs/hpc/working-around-tdr-in-windows-for-a-better-gpu-computing-experience-777/)
- [Intel - GPU Timeout Detection](https://www.intel.com/content/www/us/en/docs/oneapi/installation-guide-windows/2025-2/gpu-adjust-timeout-detection-and-recovery-setting.html)

**Registry Configuration:**
```
Path: HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\GraphicsDrivers

Values:
  TdrLevel (DWORD)
    - 0 = TDR detection disabled
    - 3 = Recover on timeout (default)
  
  TdrDelay (DWORD)
    - Number of seconds before timeout (default: 2)
    - Recommended: 8-10 for GPU compute workloads
```

**How to Modify:**
1. Open Registry Editor
2. Navigate to the path above
3. Create `TdrLevel` and `TdrDelay` if they don't exist
4. Set appropriate values
5. Restart system

**Impact on Memory Management:**
- Prevents driver reset during long-running GPU computations
- Does not directly prevent VRAM offloading but prevents interruptions
- Useful for llama server which may have long inference operations

**Risks/Side Effects:**
- Disabling TDR (`TdrLevel=0`) can cause system hangs if GPU becomes unresponsive
- Increasing `TdrDelay` is safer than disabling entirely
- May allow graphics glitches to persist longer

---

### 5. AMD Adrenalin Software Settings

**Confidence:** MED

**Evidence:**
- [AMD - GPU Performance Tuning](https://www.amd.com/en/resources/support-articles/faqs/DH3-020.html)
- [AMD - Graphics Settings](https://www.amd.com/en/resources/support-articles/faqs/DH3-012.html)

**Available Settings:**

**Smart Access Memory (SAM):**
- Allows CPU to access full GPU VRAM at once
- Should be **enabled** for optimal performance
- Location: AMD Adrenalin → Performance → Tuning → Smart Access Memory
- Requires compatible motherboard/CPU (PCIe Resizable BAR support)

**VRAM Tuning:**
- Max Frequency (%) - Adjust VRAM clock speed
- Memory Timing Presets - Default or Fast Timing (RX 5000+ series)
- **Note:** Overclocking may cause instability; damages not covered under warranty

**Power Tuning:**
- Power Limit (%) - Higher limit allows more performance headroom
- May affect how aggressively GPU enters power-saving states

**Graphics Profile:**
- Set llama-server executable to "High Performance" in Windows Graphics Settings
- Settings → System → Display → Graphics → Add app → Set to High Performance

**Risks/Side Effects:**
- VRAM overclocking can cause system instability
- AMD warranty does not cover overclocking damages
- SAM requires compatible hardware (most modern systems support it)

---

### 6. Windows Shared GPU Memory (Cannot Be Directly Controlled)

**Confidence:** HIGH

**Evidence:**
- [SuperUser - Change Shared System Memory](https://superuser.com/questions/1729847/how-do-i-change-shared-system-memory-for-gpu-in-windows-11-without-bios)
- [Microsoft Answers - Reduce Shared GPU Memory](https://learn.microsoft.com/en-us/answers/questions/3866676/subject-urgent-request-ability-to-reduce-shared-gp)

**Key Facts:**
- Windows 11 allocates up to **50% of system RAM** as shared GPU memory
- This is **automatically managed** by WDDM (Windows Display Driver Model)
- **No registry key or Windows setting** can change this allocation
- The `DedicatedSegmentSize` registry key (`HKLM\Software\Intel\GMM`) is **cosmetic only** on Windows 10/11

**For Discrete GPUs (like 7900 XT):**
- Shared memory is used when dedicated VRAM is exhausted
- Driver decides when to offload based on memory pressure and GPU activity
- Cannot be disabled through Windows settings

**BIOS/UEFI:**
- Some motherboards may have "Above 4G Decoding" or "Resizable BAR" settings
- These affect memory addressing, not shared memory allocation
- No BIOS setting directly controls Windows shared GPU memory

---

### 7. ROCm Memory Management (Windows-Specific)

**Confidence:** MED

**Evidence:**
- [AMD ROCm Documentation - GPU Memory](https://rocm.docs.amd.com/en/docs-6.1.5/conceptual/gpu-memory.html)
- [llama.cpp Issue #9964](https://github.com/ggml-org/llama.cpp/issues/9964)

**Memory Types in ROCm:**

| API | Location | Type | Notes |
|-----|----------|------|-------|
| `malloc`/`new` | Host | Pageable | Can be paged to disk |
| `hipMallocManaged` | Host/Device | Managed | Auto-migrates (Linux HMM) |
| `hipHostMalloc` | Host | Pinned | Page-locked, faster transfers |
| `hipMalloc` | Device | Pinned | Dedicated VRAM |

**Windows Limitations:**
- HMM (Heterogeneous Memory Management) is **Linux-only**
- Managed memory may not work correctly on Windows
- XNACK (page migration) may be disabled by default on Windows

**Relevant Environment Variables:**
```
HSA_XNACK=1          # Enable XNACK page migration (if supported)
HSA_ENABLE_SDMA=0    # Use blit kernels instead of SDMA (trade-off: uses compute resources)
```

**llama.cpp Specific Issue:**
- Issue #9964 reports models loading to shared GPU memory instead of dedicated VRAM on Windows ROCm
- Same hardware works correctly on Linux with ROCm 6.0.2
- Model-dependent behavior observed (some models load correctly, others don't)

---

### 8. Keep GPU Active (Prevent Idle-State Offloading)

**Confidence:** MED

**Evidence:**
- [llama.cpp Discussion #12800](https://github.com/ggml-org/llama.cpp/discussions/12800)
- Similar issue on Linux resolved with `amdgpu.runpm=0`

**Problem:**
- GPU enters low-power state when idle (no display activity)
- Driver offloads VRAM contents to system RAM during idle
- Next inference request requires reloading model to VRAM

**Windows Workarounds:**

**Option 1 - Keep GPU Busy:**
- Run a lightweight GPU monitoring tool in background
- Similar to `radeontop` on Linux
- May prevent GPU from entering idle state

**Option 2 - Disable Power Saving:**
- Windows Power Options → High Performance plan
- AMD Adrenalin → Power Tuning → Set higher power limit
- Disable ULPS (see section 2)

**Option 3 - Attach Display:**
- Issue #12800 notes problem occurs when no monitor is attached
- Keep a display connected to the GPU
- Or use a dummy display plug

---

## Contradictions

| Claim | Source A | Source B | Resolution |
|-------|----------|----------|------------|
| Shared GPU Memory adjustable | Some forums claim registry works | Microsoft/SuperUser confirm it's cosmetic | Registry key `DedicatedSegmentSize` is cosmetic only on Win 10/11 |
| HAGS improves performance | HowToGeek claims benefits | Some users report latency issues | Depends on workload; try both settings for llama server |
| `--mlock` works on Windows | llama.cpp documentation | Multiple issues report it failing | Requires `SeLockMemoryPrivilege` - fails silently without it |

---

## Sources by Reliability

**Tier 1 (Official/Authoritative):**
- [Microsoft - Lock Pages in Memory](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/security-policy-settings/lock-pages-in-memory)
- [AMD ROCm Documentation](https://rocm.docs.amd.com/en/docs-6.1.5/conceptual/gpu-memory.html)
- [AMD Adrenalin Documentation](https://www.amd.com/en/resources/support-articles/faqs/DH3-020.html)
- [Intel - TDR Settings](https://www.intel.com/content/www/us/en/docs/oneapi/installation-guide-windows/2025-2/gpu-adjust-timeout-detection-and-recovery-setting.html)
- [llama.cpp GitHub Issues](https://github.com/ggml-org/llama.cpp/issues/9964)

**Tier 2 (Reputable Secondary):**
- [HowToGeek - HAGS](https://www.howtogeek.com/756935/how-to-enable-hardware-accelerated-gpu-scheduling-in-windows-11/)
- [Puget Systems - TDR](https://www.pugetsystems.com/labs/hpc/working-around-tdr-in-windows-for-a-better-gpu-computing-experience-777/)
- [SuperUser - Shared Memory](https://superuser.com/questions/1729847/how-do-i-change-shared-system-memory-for-gpu-in-windows-11-without-bios)
- [Microsoft Answers - Shared Memory](https://learn.microsoft.com/en-us/answers/questions/3866676/subject-urgent-request-ability-to-reduce-shared-gp)

**Tier 3 (Community/Informal):**
- [VicLovan - ULPS](https://www.viclovan.com/ulps-slow-startup)
- Reddit threads on ULPS and GPU settings
- Various YouTube tutorials

---

## Recommended Action Plan

### Immediate Steps (Low Risk):

1. **Enable Lock Pages in Memory Privilege:**
   ```
   secpol.msc → Local Policies → User Rights Assignment → Lock pages in memory
   Add your user account, log off/on
   ```

2. **Disable ULPS:**
   ```
   regedit → Search for EnableULPS → Set to 0
   Reboot
   ```

3. **Disable Hardware Accelerated GPU Scheduling:**
   ```
   Settings → System → Display → Graphics Settings → HAGS Off
   OR
   regedit → HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\HwSchMode = 1
   Reboot
   ```

4. **Set Windows Power Plan to High Performance:**
   ```
   Control Panel → Power Options → High Performance
   ```

5. **Set llama-server to High Performance in Graphics Settings:**
   ```
   Settings → System → Display → Graphics → Add llama-server.exe → High Performance
   ```

### Secondary Steps (Moderate Risk):

6. **Increase TDR Delay:**
   ```
   regedit → HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\GraphicsDrivers
   Create TdrDelay (DWORD) = 10 (decimal)
   Reboot
   ```

7. **Enable Smart Access Memory in AMD Adrenalin:**
   ```
   AMD Adrenalin → Performance → Tuning → Smart Access Memory → Enabled
   ```

8. **Keep GPU Active:**
   - Run GPU monitoring tool in background
   - Or keep display connected to GPU

### Advanced Steps (Higher Risk):

9. **Disable TDR Entirely (not recommended):**
   ```
   regedit → HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\GraphicsDrivers
   Create TdrLevel (DWORD) = 0
   Reboot
   ```
   **Warning:** Can cause system hangs if GPU becomes unresponsive.

10. **VRAM Overclocking (warranty void):**
    - AMD Adrenalin → Performance → Tuning → VRAM Tuning
    - **Not recommended** - may cause instability

---

## Unanswered Questions

1. **Why does `--mlock` fail silently on Windows?** - llama.cpp should report an error when privilege is missing
2. **Is there a Windows equivalent to Linux `amdgpu.runpm=0`?** - No direct equivalent found
3. **Does ROCm Windows support managed memory with page migration?** - Documentation suggests HMM is Linux-only
4. **Why do some models load to dedicated VRAM while others use shared memory?** - Issue #9964 reports model-dependent behavior without clear explanation

---

## Alternative: Consider WSL2/Linux

**Confidence:** MED

**Evidence:**
- [llama.cpp Issue #9964](https://github.com/ggml-org/llama.cpp/issues/9964) - Reports same hardware works correctly on Linux with ROCm 6.0.2

**Key Finding from Issue #9964:**
- Same RX 7900 XT hardware that shows shared memory issues on Windows ROCm 6.1.2
- Works correctly on **Arch Linux with ROCm 6.0.2**
- Models load to dedicated VRAM as expected
- No performance degradation observed

**Consider WSL2 if:**
- Windows solutions don't resolve the issue
- You can run llama-server in WSL2 with GPU passthrough
- Note: WSL2 ROCm support has its own complexities

**Relevant Discussion:**
- [Can't run ROCM on Windows 10 with WSL2](https://www.reddit.com/r/ROCm/comments/1doxxuc/cant_run_rocm_on_windows_10_with_wsl2_ubuntu_2200/)
- WSL2 GPU support is improving but ROCm passthrough remains challenging

---

## Additional Notes for AMD Radeon 7900 XT

- **20GB VRAM** should be sufficient for most llama.cpp models without offloading
- **ROCm 6.1.2+** recommended for Windows support
- **gfx1100** is the correct target architecture for 7900 XT
- Ensure latest AMD Adrenalin drivers are installed
- Check that "Above 4G Decoding" is enabled in BIOS for Resizable BAR/SAM support

---

## Summary Table

| Method | Effectiveness | Risk | Requires Reboot |
|--------|---------------|------|-----------------|
| Lock Pages in Memory | HIGH (required for --mlock) | LOW | Yes (log off/on) |
| Disable ULPS | HIGH (prevents idle offloading) | LOW | Yes |
| Disable HAGS | MED (may reduce aggressive management) | LOW | Yes |
| Increase TDR Delay | MED (prevents driver resets) | LOW | Yes |
| High Performance Power Plan | MED (keeps GPU active) | LOW | No |
| Smart Access Memory | MED (improves memory access) | LOW | Yes |
| Disable TDR | LOW (doesn't prevent offloading) | HIGH | Yes |
| VRAM Overclocking | UNKNOWN | HIGH | Yes |

---

**Generated:** March 5, 2026
**Research Duration:** ~2 hours
**Sources Consulted:** 20+
