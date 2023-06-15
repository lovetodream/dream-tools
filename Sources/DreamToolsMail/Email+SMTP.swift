import Vapor
import Smtp

public enum SMTP {
    /// Sets up SMTP for the application with the provided environment variables.
    ///
    /// If no username and password is provided nor can be fetched from the environment the setup assumes you want to login to the SMTP server anonymously.
    /// The setup process looks into the environment if `MAIL_INSECURE` is provided, if it is not the setup will connect to the server using StartTLS if available.
    ///
    /// - Parameter app: The application which should be configured.
    /// - Parameter hostname: The hostname for the SMTP server, it tries to get it from the environment on `MAIL_HOST`, otherwise it will be empty.
    /// - Parameter port: The port for the SMTP server, it tries to get it from the environment on `MAIL_PORT`, otherwise it will be `25`.
    /// - Parameter username: The optional username for the SMTP server, it tries to get it from the environment on `MAIL_USERNAME`.
    /// - Parameter password: The optional password for the SMTP server, it tries to get it from the environment on `MAIL_PASSWORD`.
    public static func setup(on app: Application,
                             hostname: String? = Environment.get("MAIL_HOST"),
                             port: Int? = Environment.get("MAIL_PORT").flatMap(Int.init),
                             username: String? = Environment.get("MAIL_USERNAME"),
                             password: String? = Environment.get("MAIL_PASSWORD")) {
        app.smtp.configuration.hostname = hostname ?? ""
        app.smtp.configuration.port = port ?? 25
        app.smtp.configuration.secure = Environment.get("MAIL_INSECURE") != nil ? .none : .startTlsWhenAvailable

        if let username = username, let password = password {
            app.smtp.configuration.signInMethod = .credentials(username: username, password: password)
        } else {
            app.smtp.configuration.signInMethod = .anonymous
        }
    }
}

// MARK: - Generic Shared Email Context

extension EmailAddress: Content {
    enum CodingKeys: CodingKey {
        case address
        case name
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let address = try values.decode(String.self, forKey: .address)
        let name = try values.decodeIfPresent(String.self, forKey: .name)
        self.init(address: address, name: name)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encodeIfPresent(name, forKey: .name)
    }
}

/// A generic email context with a single call to action.
/// Useful for Email Validation, Password Reset, Account Deletion or other "url based" actions.
public struct GenericCtaEmailContext: Content {
    public var subject: String
    public var from: EmailAddress
    public var to: [EmailAddress]?
    public var cc: [EmailAddress]?
    public var bcc: [EmailAddress]?
    public var replyTo: EmailAddress?
    public var reference: String?
    public var title: String
    public var preheader: String
    public var imageUrl: String?
    public var greeting: String
    public var headline: String
    public var ctaDescription: String
    public var ctaDestination: String
    public var ctaLabel: String
    public var wrongRecipientDescription: String
    public var thanksGreeting: String
    public var thanksGreeter: String
    public var copyrightYear: String

    /// Initializes a generic call to action email context with the provided parameters.
    ///
    /// - Important: You need to provide a non-nil value either to `to`, `cc`, `bcc`, if non of them is provided, an error will be thrown on a later stage of the process.
    ///
    /// ```
    /// =========================================================
    /// |                                                       |
    /// |                         Image                         |
    /// |                                                       |
    /// |   =================================================   |
    /// |   |                                               |   |
    /// |   |   Greeting                                    |   |
    /// |   |                                               |   |
    /// |   |   # Headline                                  |   |
    /// |   |                                               |   |
    /// |   |   CTA Description                             |   |
    /// |   |   =================                           |   |
    /// |   |   |   CTA Label   |                           |   |
    /// |   |   =================                           |   |
    /// |   |                                               |   |
    /// |   |   -----------------------------------------   |   |
    /// |   |                                               |   |
    /// |   |   Wrong Recipient Description                 |   |
    /// |   |                                               |   |
    /// |   |   Thanks Greeting                             |   |
    /// |   |   Thanks Greeter                              |   |
    /// |   |                                               |   |
    /// |   =================================================   |
    /// |                                                       |
    /// |                   Copyright and Legal                 |
    /// |                                                       |
    /// =========================================================
    /// ```
    ///
    /// - Parameters:
    ///   - subject: The subject of the email.
    ///   - from: The sender of the email, it is ``Constants.Email.noReply``.
    ///   - to: The primary recipients of the email.
    ///   - cc: The secondary recipients of the email.
    ///   - bcc: The hidden recipients of the email.
    ///   - replyTo: The email address, which should be used in case of a reply.
    ///   - reference: A reference string to identify the email further.
    ///   - title: The title of the emails content, it will not be visible inside the email, but it might be shown in the list of emails on the client.
    ///   - preheader: The preheader is similar to the `title`, but it is not always visible in the list of emails on the client. It should be a quick overview of the email's content.
    ///   - imageUrl: A url to an image, which should be displayed inside the email as a logo on top.
    ///   - greeting: The greeting is displayed on top of the email, if an image is provided, it will be displayed below it. It is "Hello," by default.
    ///   - headline: The headline of the email, it will be displayed prominently below the `greeting`. It is the most eye caching content after the call to action button.
    ///   - ctaDescription: The description of the call to action button, it will be displayed below the headline, and on top of the button. It has a default body size.
    ///   - ctaDestination: The destination of the call to action button, most likely it is an url pointing to any resource.
    ///   - ctaLabel: The label of the call to action button, it should be short and precise, so the user knows what happens when pressing it. If more context is required, specify it in the `ctaDescription`.
    ///   - wrongRecipientDescription: This is displayed below the button and indicates to the recipient what he should do if the email is not desired for him.
    ///   - thanksGreeting: This is a greeting from the sender of the email, for example "Thanks,".
    ///   - thanksGreeter: This is the person/institution which is greeting the recipient.
    public init(subject: String,
                from: EmailAddress = Constants.Mail.noReply,
                to: [EmailAddress]? = nil,
                cc: [EmailAddress]? = nil,
                bcc: [EmailAddress]? = nil,
                replyTo: EmailAddress? = nil,
                reference: String? = nil,
                title: String? = nil,
                preheader: String,
                imageUrl: String? = nil,
                greeting: String = "Hello,",
                headline: String,
                ctaDescription: String,
                ctaDestination: String,
                ctaLabel: String,
                wrongRecipientDescription: String = "If you're not sure why you received this email, you can ignore it.",
                thanksGreeting: String = "Thanks,",
                thanksGreeter: String = "The Team") {
        self.subject = subject
        self.from = from
        self.to = to
        self.cc = cc
        self.bcc = bcc
        self.replyTo = replyTo
        self.reference = reference
        self.title = title ?? subject
        self.preheader = preheader
        self.imageUrl = imageUrl
        self.greeting = greeting
        self.headline = headline
        self.ctaDescription = ctaDescription
        self.ctaDestination = ctaDestination
        self.ctaLabel = ctaLabel
        self.wrongRecipientDescription = wrongRecipientDescription
        self.thanksGreeting = thanksGreeting
        self.thanksGreeter = thanksGreeter
        self.copyrightYear = {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .none
            dateFormatter.dateFormat = "y"
            return dateFormatter.string(from: Date())
        }()
    }
}

// MARK: - Email Rendering

public enum EmailTemplate {
    /// Used to render an HTML email from a Leaf template with the provided context.
    public static func render<E>(_ name: String, with context: E, on req: Request) async throws -> String where E: Encodable {
        try await String(buffer: req.view.render(name, context).data)
    }
}
