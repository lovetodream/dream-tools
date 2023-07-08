/// It converts a non public model to a public representation of itself.
public protocol PublicConvertible {
    associatedtype Public: Codable

    /// The method used to convert a non public model to a public representation of itself.
    /// It will also be available on Collections of the former.
    func convertToPublic() -> Public
}

public extension Collection where Element: PublicConvertible {
    func convertToPublic() -> [Element.Public] {
        return self.map { $0.convertToPublic() }
    }
}

public protocol ThrowingPublicConvertible {
    associatedtype Public: Codable

    func convertToPublic() throws -> Public
}

public extension Collection where Element: ThrowingPublicConvertible {
    func convertToPublic() throws -> [Element.Public] {
        return try self.map { try $0.convertToPublic() }
    }
}
