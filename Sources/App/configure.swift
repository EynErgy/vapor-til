import FluentMySQL
import Vapor

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)


    /// Register the configured MySQL database to the database config.
    var databases = DatabaseConfig()
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    let databaseConfig = MySQLDatabaseConfig(
        hostname: hostname,
        username: username,
        password: password,
        database: databaseName
    )
    let database = MySQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .mysql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Acronym.self, database: .mysql)
    services.register(migrations)

}
