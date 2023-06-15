import Vapor
import JWT

public enum JWT {
    /// Sets the public JWT key as the default JWT signer of the application.
    ///
    /// The key data is be obtained from the Environment `PUBLIC_RSA_KEY_FOR_SIGNING` as base64 encoded data.
    /// If you want to sign JWT tokens please use ``static JWT.private(app:)`` instead.
    ///
    /// - Parameter app: The application, which should be configured.
    public static func `public`(app: Application) throws {
        guard let publicKeyData = Environment.get("PUBLIC_RSA_KEY_FOR_VERIFYING"),
              let publicKey = Data(base64Encoded: publicKeyData) else {
            fatalError("You need to provide a PUBLIC_RSA_KEY_FOR_VERIFYING as an environment variable!")
        }

        try app.jwt.signers.use(.rs256(key: .public(pem: publicKey)))
    }

    /// Sets the private JWT key as the default JWT signer of the application.
    ///
    /// The key data is be obtained from the Environment `PRIVATE_RSA_KEY_FOR_SIGNING` as base64 encoded data.
    /// If you do not need to sign JWT tokens please use ``static JWT.public(app:)`` instead.
    ///
    /// - Parameter app: The application, which should be configured.
    public static func `private`(app: Application) throws {
        guard let privateKeyData = Environment.get("PRIVATE_RSA_KEY_FOR_SIGNING"),
              let privateKey = Data(base64Encoded: privateKeyData) else {
            fatalError("You need to provide a PRIVATE_RSA_KEY_FOR_SIGNING as an environment variable!")
        }

        try app.jwt.signers.use(.rs256(key: .private(pem: privateKey)))
    }
}
