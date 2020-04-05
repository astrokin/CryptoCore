import Foundation

/**
 * Adopters can generate entropy; a random set of bytes.
 */
public protocol EntropyGenerator {
    func entropy() -> Result<Data,Error>
}

/**
 * Errors relating to `EntropyGenerator`.
 */
public enum EntropyGeneratorError: Swift.Error {
    case invalidInput(String)
}

extension EntropyGenerator where Self: StringProtocol {
    /**
     * Interprets `self` as a string of pre-computed _entropy_, at least if its
     * of even length, and between 32 & 64 characters.
     *
     *  E.g., "7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f".
     */
    public func entropy() -> Result<Data, Error> {
        guard (count % 2) == 0, case 4...8 = (count / 8) else {
            return .failure(EntropyGeneratorError.invalidInput(String(self)))
        }
        
        var values  = [Int32?]()
        for (idx, char) in self.enumerated() {
            // Break up `self` into character-pairs, representing a single hex.
            if idx % 2 == 1 {
                let prevIdx = self.index(before: String.Index(utf16Offset: idx, in: self))
                let prevChr = self[prevIdx]
                let value   = Scanner(string: "\(prevChr)\(char)").scanInt32(representation: .hexadecimal)
                values.append(value)
            }
        }
        return .success(Data(values.compactMap { $0 }.map(UInt8.init)))
    }
}

extension String: EntropyGenerator { }
extension String.SubSequence: EntropyGenerator { }

