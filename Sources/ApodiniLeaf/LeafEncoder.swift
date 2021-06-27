// This code is based on the Vapor project: https://github.com/vapor/leaf
//
// The MIT License (MIT)
//
// Copyright (c) 2018 Qutheory, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


// swiftlint:disable fatal_error_message
// swiftlint:disable force_unwrapping

import LeafKit


internal final class LeafEncoder {
    func encode<E: Encodable>(_ encodable: E) throws -> [String: LeafData] {
        let encoder = _Encoder(codingPath: [])
        try encodable.encode(to: encoder)
        let data = encoder.container!.data!.resolve()
        guard let dictionary = data.dictionary else {
            throw LeafError(.unsupportedFeature("You must use a top level dictionary or type for the context. Arrays are not allowed"))
        }
        return dictionary
    }
}


// MARK: - Private

private protocol _Container {
    var data: _Data? { get }
}


private enum _Data {
    case container(_Container)
    case data(LeafData)
    
    
    func resolve() -> LeafData {
        switch self {
        case .container(let container):
            return container.data!.resolve()
        case .data(let data):
            return data
        }
    }
}


// MARK: `Encoder`
private final class _Encoder: Encoder {
    var userInfo: [CodingUserInfoKey: Any] { [:] }
    let codingPath: [CodingKey]
    var container: _Container?
    
    
    /// Creates a new form url-encoded encoder
    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
        self.container = nil
    }
    
    
    /// See `Encoder`
    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        let container = KeyedContainer<Key>(codingPath: codingPath)
        self.container = container
        return .init(container)
    }

    /// See `Encoder`
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = UnkeyedContainer(codingPath: codingPath)
        self.container = container
        return container
    }

    /// See `Encoder`
    func singleValueContainer() -> SingleValueEncodingContainer {
        let container = SingleValueContainer(codingPath: codingPath)
        self.container = container
        return container
    }
}


/// Private `SingleValueEncodingContainer`.
private final class SingleValueContainer: SingleValueEncodingContainer, _Container {
    /// See `SingleValueEncodingContainer`
    var codingPath: [CodingKey]
    /// The data being encoded
    var data: _Data?
    
    
    /// Creates a new single value encoder
    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }
    
    /// See `SingleValueEncodingContainer`
    func encodeNil() throws {
        // skip
    }
    
    
    /// See `SingleValueEncodingContainer`
    func encode<T: Encodable>(_ value: T) throws {
        if let leafRepresentable = value as? LeafDataRepresentable {
            self.data = .data(leafRepresentable.leafData)
        } else {
            let encoder = _Encoder(codingPath: self.codingPath)
            try value.encode(to: encoder)
            self.data = encoder.container!.data
        }
    }
}


/// Private `KeyedEncodingContainerProtocol`.
private final class KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol, _Container {
    var codingPath: [CodingKey]
    var dictionary: [String: _Data]
    
    
    var data: _Data? {
        .data(.dictionary(self.dictionary.mapValues { $0.resolve() }))
    }
    
    
    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
        self.dictionary = [:]
    }
    
    
    /// See `KeyedEncodingContainerProtocol`
    func encodeNil(forKey key: Key) throws {
        // skip
    }

    /// See `KeyedEncodingContainerProtocol`
    func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        if let leafRepresentable = value as? LeafDataRepresentable {
            self.dictionary[key.stringValue] = .data(leafRepresentable.leafData)
        } else {
            let encoder = _Encoder(codingPath: codingPath + [key])
            try value.encode(to: encoder)
            self.dictionary[key.stringValue] = encoder.container!.data
        }
    }
    
    /// See `KeyedEncodingContainerProtocol`
    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let container = KeyedContainer<NestedKey>(codingPath: self.codingPath + [key])
        self.dictionary[key.stringValue] = .container(container)
        return .init(container)
    }
    
    /// See `KeyedEncodingContainerProtocol`
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = UnkeyedContainer(codingPath: self.codingPath + [key])
        self.dictionary[key.stringValue] = .container(container)
        return container
    }
    
    /// See `KeyedEncodingContainerProtocol`
    func superEncoder() -> Encoder {
        fatalError()
    }
    
    /// See `KeyedEncodingContainerProtocol`
    func superEncoder(forKey key: Key) -> Encoder {
        fatalError()
    }
}

// MARK: `UnkeyedEncodingContainer`.
private final class UnkeyedContainer: UnkeyedEncodingContainer, _Container {
    var codingPath: [CodingKey]
    var count: Int
    var array: [_Data]
    
    
    var data: _Data? {
        .data(.array(self.array.map { $0.resolve() }))
    }
    
    
    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
        self.count = 0
        self.array = []
    }
    
    
    func encodeNil() throws {
        // skip
    }
    
    func encode<T>(_ value: T) throws where T: Encodable {
        defer { self.count += 1 }
        if let leafRepresentable = value as? LeafDataRepresentable {
            self.array.append(.data(leafRepresentable.leafData))
        } else {
            let encoder = _Encoder(codingPath: codingPath)
            try value.encode(to: encoder)
            self.array.append(encoder.container!.data!)
        }
    }
    
    /// See UnkeyedEncodingContainer.nestedContainer
    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        defer { self.count += 1 }
        let container = KeyedContainer<NestedKey>(codingPath: self.codingPath)
        self.array.append(.container(container))
        return .init(container)
    }
    
    /// See UnkeyedEncodingContainer.nestedUnkeyedContainer
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        defer { self.count += 1 }
        let container = UnkeyedContainer(codingPath: self.codingPath)
        self.array.append(.container(container))
        return container
    }
    
    /// See UnkeyedEncodingContainer.superEncoder
    func superEncoder() -> Encoder {
        fatalError()
    }
}


private extension EncodingError {
    static func invalidValue(_ value: Any, at path: [CodingKey]) -> EncodingError {
        let pathString = path.map { $0.stringValue }.joined(separator: ".")
        let context = EncodingError.Context(
            codingPath: path,
            debugDescription: "Invalid value at '\(pathString)': \(value)"
        )
        return Swift.EncodingError.invalidValue(value, context)
    }
}
