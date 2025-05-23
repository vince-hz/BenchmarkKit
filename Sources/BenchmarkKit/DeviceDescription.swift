import Foundation

private func deviceIdentifier() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machine = withUnsafePointer(to: &systemInfo.machine) {
        ptr in String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
    }
    return machine
}

private func safeCStringToString(_ buffer: [CChar]) -> String {
    guard let nulIndex = buffer.firstIndex(of: 0) else {
        let u8 = buffer.map { UInt8(bitPattern: $0) }
        return String(decoding: u8, as: UTF8.self)
    }

    let trimmed = buffer[..<nulIndex].map { UInt8(bitPattern: $0) }
    return String(decoding: trimmed, as: UTF8.self)
}

private func sysctlString(for name: String) -> String? {
    var size = 0
    if sysctlbyname(name, nil, &size, nil, 0) != 0 { return nil }
    var buffer = [CChar](repeating: 0, count: size)
    if sysctlbyname(name, &buffer, &size, nil, 0) != 0 { return nil }
    return safeCStringToString(buffer)
}

private func sysctlInt(for name: String) -> Int? {
    var value: Int = 0
    var size = MemoryLayout<Int>.size
    return sysctlbyname(name, &value, &size, nil, 0) == 0 ? value : nil
}

func deviceDescription() -> String {
    let modelIdentifier = deviceIdentifier()

    let logicalCores = sysctlInt(for: "hw.logicalcpu") ?? 0
    let physicalCores = sysctlInt(for: "hw.physicalcpu") ?? 0

    let memoryBytes = ProcessInfo.processInfo.physicalMemory
    let memoryGB = memoryBytes / (1024 * 1024 * 1024)

    let d = String(
        format:
"""
%@
physical cpu: %d; logic cpu: %d
memory: %d GB
""",
        modelIdentifier,
        physicalCores,
        logicalCores,
        memoryGB
    )
    return d
}
