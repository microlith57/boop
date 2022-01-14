# Boop

Boop is a web application which acts like a library checkout system, but for computers, allowing for an efficient barcode-based issue/return workflow.

Its current main goal is to be better than writing on paper.

## Requirements

Boop requires Ruby 3.0.1, Bundler, Node 10, Yarn, and preferably a Linux environment.
It must be connected to a PostgreSQL database.

To install it in a consistent environment, a [Docker Compose configuration](https://github.com/microlith57/boop_docker/pkgs/container/boop_docker%2Fboop) is provided; this is the recommended method of installaton.

## Manual Installation

1. Clone this repository (`git clone https://github.com/microlith57/boop.git --depth 1`)
2. Run `bin/bundle install` and `bin/yarn install` to install dependencies
3. Configure environment variables as below
4. Run `bin/rails secret`
5. Run `RAILS_ENV=production bin/rails db:prepare` to prepare the production database
6. Run `RAILS_ENV=production bin/rails log:clear tmp:clear assets:precompile` to clear the temporary files and logs, and precompile the necessary assets

### Environment Variables

Environment variables can be configured using `.env` files.
It is recommended to create a file `.env.production.local` in the `boop` directory, and place overrides there.
You must set the following:

- `NODE_ENV=production`
- `POSTGRES_HOST` to the database hostname (eg. `localhost`)
- `POSTGRES_PORT` to the database port (eg. `5432`)
- `POSTGRES_USERNAME` and `POSTGRES_PASSWORD` to the database credentials
- `RAILS_SERVE_STATIC_FILES` to `true` (unless you have a web server set to handle this)

## Updates

1. Pull the latest changes (`git pull` or download a new version)
2. Run `bin/bundle install` and `bin/yarn install` to update dependencies
3. Run `RAILS_ENV=production bin/rails db:migrate` to migrate any database changes
4. Store old logs somewhere if necessary
5. Run `RAILS_ENV=production bin/rails log:clear tmp:clear assets:precompile` to clear the temporary files and logs, and precompile the necessary assets

## Usage

To start the server, run `bin/rails server -e production`; see the Rails documentation for more details.

### Admin Accounts

Currently, no user interface exists to create new accounts or edit existing ones; this requires the use of the Rails console (`bin/rails console -e production`).
Using an external editor for editing passwords is not recommended because the passwords are hashed before storage.

To create an account via the console:

```ruby
Admin.create email: 'new_user@example.org', password: '12345'
```

To edit an existing account:

```ruby
admin = Admin.find_by! email: 'user@example.org'

# Edit email
admin.email = 'edited_user@example.org'
# Edit password
admin.password = '54321'

admin.save!
```

To delete an admin:

```ruby
admin = Admin.find_by! email: 'user@example.org'
admin.destroy
```
