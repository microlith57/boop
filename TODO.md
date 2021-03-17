TODOs
=====

- Rename issuers to borrowers
- Search doesn't work in some cases
- Device CSV download only downloads 1 page

---

- Staff can book devices in the future
  - Form layout:
    ```
    User ID           [______]
    ---
    (if allocating normally)
    Allocation End    [datetime picker | hh:mm from now]
    (if scheduling allocation)
    Allocation Start  [datetime picker]
    Allocation End    [datetime picker w/ durations]
    ---
    Device ID Match   [ID | List of IDs (selecty thing) | Group]
    Number of Devices [__ | all]
    ```
    - Allow repeats?
      - Future version (non-core functionality)
  - Set aside devices immediately
    - If allocating from group, don't allocate specific devices immediately, just attach the allocation to the group instance and reserve correct number of devices
      - calculate remaining unallocated devices in group on-the-fly
    - print out ticket w/ allocation ID + barcode?
  - Allocating all requires special privilege/checkbox or something.
  - Notify if allocation is not possible.
    - When to notify?
    - How would this happen?
- Groups
  - Each device is in exactly one group
  - Each group is in a parent group
    - How to implement root group?
  - When allocating individual device, must use ID
  - When allocating in bulk, can use a group — will pick any available device from group (including children).
    - Can visualise group health (how?)
- Devices
  - Another state exists now - allocated but still physically in storage (not issued)
    - Replace `device#issuer : Issuer` with `device#allocator : Issuer | Allocation`
- Need to make sure all the words used are the right ones!
