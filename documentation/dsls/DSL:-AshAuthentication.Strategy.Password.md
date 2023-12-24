<!--
This file was generated by Spark. Do not edit it by hand.
-->
# DSL: AshAuthentication.Strategy.Password

Strategy for authenticating using local resources as the source of truth.

In order to use password authentication your resource needs to meet the
following minimum requirements:

1. Have a primary key.
2. A uniquely constrained identity field (eg `username` or `email`).
3. A sensitive string field within which to store the hashed password.

There are other options documented in the DSL.

### Example:

```elixir
defmodule MyApp.Accounts.User do
  use Ash.Resource,
    extensions: [AshAuthentication]

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
  end

  authentication do
    api MyApp.Accounts

    strategies do
      password :password do
        identity_field :email
        hashed_password_field :hashed_password
      end
    end
  end

  identities do
    identity :unique_email, [:email]
  end
end
```

## Actions

By default the password strategy will automatically generate the register,
sign-in, reset-request and reset actions for you, however you're free to
define them yourself.  If you do, then the action will be validated to ensure
that all the needed configuration is present.

If you wish to work with the actions directly from your code you can do so via
the `AshAuthentication.Strategy` protocol.

### Examples:

Interacting with the actions directly:

    iex> strategy = Info.strategy!(Example.User, :password)
    ...> {:ok, marty} = Strategy.action(strategy, :register, %{"username" => "marty", "password" => "outatime1985", "password_confirmation" => "outatime1985"})
    ...> marty.username |> to_string()
    "marty"

    ...> {:ok, user} = Strategy.action(strategy, :sign_in, %{"username" => "marty", "password" => "outatime1985"})
    ...> user.username |> to_string()
    "marty"

## Plugs

The password strategy provides plug endpoints for all four actions, although
only sign-in and register will be reported by `Strategy.routes/1` if the
strategy is not configured as resettable.

If you wish to work with the plugs directly, you can do so via the
`AshAuthentication.Strategy` protocol.

### Examples:

Dispatching to plugs directly:

    iex> strategy = Info.strategy!(Example.User, :password)
    ...> conn = conn(:post, "/user/password/register", %{"user" => %{"username" => "marty", "password" => "outatime1985", "password_confirmation" => "outatime1985"}})
    ...> conn = Strategy.plug(strategy, :register, conn)
    ...> {_conn, {:ok, marty}} = Plug.Helpers.get_authentication_result(conn)
    ...> marty.username |> to_string()
    "marty"

    ...> conn = conn(:post, "/user/password/reset_request", %{"user" => %{"username" => "marty"}})
    ...> conn = Strategy.plug(strategy, :reset_request, conn)
    ...> {_conn, :ok} = Plug.Helpers.get_authentication_result(conn)

## Testing

See the [Testing guide](/documentation/topics/testing.md) for tips on testing resources using this strategy.

## DSL Documentation

Strategy for authenticating using local resources as the source of truth.

  * resettable

Examples:
```
password :password do
  identity_field :email
  hashed_password_field :hashed_password
  hash_provider AshAuthentication.BcryptProvider
  confirmation_required? true
end

```


* `:identity_field` (`t:atom/0`) - The name of the attribute which uniquely identifies the user.  
  Usually something like `username` or `email_address`. The default value is `:username`.

* `:hashed_password_field` (`t:atom/0`) - The name of the attribute within which to store the user's password
  once it has been hashed. The default value is `:hashed_password`.

* `:hash_provider` (`t:atom/0`) - A module which implements the `AshAuthentication.HashProvider`
  behaviour.  
  Used to provide cryptographic hashing of passwords. The default value is `AshAuthentication.BcryptProvider`.

* `:confirmation_required?` (`t:boolean/0`) - Whether a password confirmation field is required when registering or
  changing passwords. The default value is `true`.

* `:register_action_accept` (list of `t:atom/0`) - A list of additional fields to be accepted in the register action. The default value is `[]`.

* `:password_field` (`t:atom/0`) - The name of the argument used to collect the user's password in
  plaintext when registering, checking or changing passwords. The default value is `:password`.

* `:password_confirmation_field` (`t:atom/0`) - The name of the argument used to confirm the user's password in
  plaintext when registering or changing passwords. The default value is `:password_confirmation`.

* `:register_action_name` (`t:atom/0`) - The name to use for the register action.  
  If not present it will be generated by prepending the strategy name
  with `register_with_`.

* `:registration_enabled?` (`t:boolean/0`) - If you do not want new users to be able to register using this
  strategy, set this to false. The default value is `true`.

* `:sign_in_action_name` (`t:atom/0`) - The name to use for the sign in action.  
  If not present it will be generated by prepending the strategy name
  with `sign_in_with_`.

* `:sign_in_enabled?` (`t:boolean/0`) - If you do not want new users to be able to sign in using this
  strategy, set this to false. The default value is `true`.

* `:sign_in_tokens_enabled?` (`t:boolean/0`) - Whether or not to support generating short lived sign in tokens. Requires the resource to have
  tokens enabled. There is no drawback to supporting this, and in the future this default will
  change from `false` to `true`.  
  Sign in tokens can be generated on request by setting the `:token_type` context to `:sign_in`
  when calling the sign in action. You might do this when you need to generate a short lived token
  to be exchanged for a real token using the `validate_sign_in_token` route. This is used, for example,
  by `ash_authentication_phoenix` (since 1.7) to support signing in in a liveview, and then redirecting
  with a valid token to a controller action, allowing the liveview to show invalid username/password errors. The default value is `false`.

* `:sign_in_token_lifetime` - A lifetime for which a generated sign in token will be valid, if `sign_in_tokens_enabled?`.  
  If no unit is specified, defaults to `:seconds`. The default value is `{60, :seconds}`.



### resettable

Configure password reset options for the resource





* `:token_lifetime` - How long should the reset token be valid.  
  If no unit is provided `:hours` is assumed.  
  Defaults to 3 days. The default value is `{3, :days}`.

* `:request_password_reset_action_name` (`t:atom/0`) - The name to use for the action which generates a password reset token.  
  If not present it will be generated by prepending the strategy name
  with `request_password_reset_with_`.

* `:password_reset_action_name` (`t:atom/0`) - The name to use for the action which actually resets the user's
  password.  
  If not present it will be generated by prepending the strategy name
  with `password_reset_with_`.

* `:sender` - Required. How to send the password reset instructions to the user.  
  Allows you to glue sending of reset instructions to [swoosh](https://hex.pm/packages/swoosh), [ex_twilio](https://hex.pm/packages/ex_twilio) or whatever notification system is appropriate for your application.  
  Accepts a module, module and opts, or a function that takes a record, reset token and options.  
  See `AshAuthentication.Sender` for more information.









## authentication.strategies.password
```elixir
password name \\ :password
```


Strategy for authenticating using local resources as the source of truth.

### Nested DSLs
 * [resettable](#authentication-strategies-password-resettable)


### Examples
```
password :password do
  identity_field :email
  hashed_password_field :hashed_password
  hash_provider AshAuthentication.BcryptProvider
  confirmation_required? true
end

```




### Options

| Name | Type | Default | Docs |
|------|------|---------|------|
| [`identity_field`](#authentication-strategies-password-identity_field){: #authentication-strategies-password-identity_field } | `atom` | `:username` | The name of the attribute which uniquely identifies the user. Usually something like `username` or `email_address`. |
| [`hashed_password_field`](#authentication-strategies-password-hashed_password_field){: #authentication-strategies-password-hashed_password_field } | `atom` | `:hashed_password` | The name of the attribute within which to store the user's password once it has been hashed. |
| [`hash_provider`](#authentication-strategies-password-hash_provider){: #authentication-strategies-password-hash_provider } | `module` | `AshAuthentication.BcryptProvider` | A module which implements the `AshAuthentication.HashProvider` behaviour. Used to provide cryptographic hashing of passwords. |
| [`confirmation_required?`](#authentication-strategies-password-confirmation_required?){: #authentication-strategies-password-confirmation_required? } | `boolean` | `true` | Whether a password confirmation field is required when registering or changing passwords. |
| [`register_action_accept`](#authentication-strategies-password-register_action_accept){: #authentication-strategies-password-register_action_accept } | `list(atom)` | `[]` | A list of additional fields to be accepted in the register action. |
| [`password_field`](#authentication-strategies-password-password_field){: #authentication-strategies-password-password_field } | `atom` | `:password` | The name of the argument used to collect the user's password in plaintext when registering, checking or changing passwords. |
| [`password_confirmation_field`](#authentication-strategies-password-password_confirmation_field){: #authentication-strategies-password-password_confirmation_field } | `atom` | `:password_confirmation` | The name of the argument used to confirm the user's password in plaintext when registering or changing passwords. |
| [`register_action_name`](#authentication-strategies-password-register_action_name){: #authentication-strategies-password-register_action_name } | `atom` |  | The name to use for the register action. If not present it will be generated by prepending the strategy name with `register_with_`. |
| [`registration_enabled?`](#authentication-strategies-password-registration_enabled?){: #authentication-strategies-password-registration_enabled? } | `boolean` | `true` | If you do not want new users to be able to register using this strategy, set this to false. |
| [`sign_in_action_name`](#authentication-strategies-password-sign_in_action_name){: #authentication-strategies-password-sign_in_action_name } | `atom` |  | The name to use for the sign in action. If not present it will be generated by prepending the strategy name with `sign_in_with_`. |
| [`sign_in_enabled?`](#authentication-strategies-password-sign_in_enabled?){: #authentication-strategies-password-sign_in_enabled? } | `boolean` | `true` | If you do not want new users to be able to sign in using this strategy, set this to false. |
| [`sign_in_tokens_enabled?`](#authentication-strategies-password-sign_in_tokens_enabled?){: #authentication-strategies-password-sign_in_tokens_enabled? } | `boolean` | `false` | Whether or not to support generating short lived sign in tokens. Requires the resource to have tokens enabled. There is no drawback to supporting this, and in the future this default will change from `false` to `true`. Sign in tokens can be generated on request by setting the `:token_type` context to `:sign_in` when calling the sign in action. You might do this when you need to generate a short lived token to be exchanged for a real token using the `validate_sign_in_token` route. This is used, for example, by `ash_authentication_phoenix` (since 1.7) to support signing in in a liveview, and then redirecting with a valid token to a controller action, allowing the liveview to show invalid username/password errors. |
| [`sign_in_token_lifetime`](#authentication-strategies-password-sign_in_token_lifetime){: #authentication-strategies-password-sign_in_token_lifetime } | `pos_integer \| {pos_integer, :days \| :hours \| :minutes \| :seconds}` | `{60, :seconds}` | A lifetime for which a generated sign in token will be valid, if `sign_in_tokens_enabled?`. If no unit is specified, defaults to `:seconds`. |


## authentication.strategies.password.resettable


Configure password reset options for the resource






### Options

| Name | Type | Default | Docs |
|------|------|---------|------|
| [`sender`](#authentication-strategies-password-resettable-sender){: #authentication-strategies-password-resettable-sender .spark-required} | `(any, any, any -> any) \| module` |  | How to send the password reset instructions to the user. Allows you to glue sending of reset instructions to [swoosh](https://hex.pm/packages/swoosh), [ex_twilio](https://hex.pm/packages/ex_twilio) or whatever notification system is appropriate for your application. Accepts a module, module and opts, or a function that takes a record, reset token and options. See `AshAuthentication.Sender` for more information. |
| [`token_lifetime`](#authentication-strategies-password-resettable-token_lifetime){: #authentication-strategies-password-resettable-token_lifetime } | `pos_integer \| {pos_integer, :days \| :hours \| :minutes \| :seconds}` | `{3, :days}` | How long should the reset token be valid. If no unit is provided `:hours` is assumed. Defaults to 3 days. |
| [`request_password_reset_action_name`](#authentication-strategies-password-resettable-request_password_reset_action_name){: #authentication-strategies-password-resettable-request_password_reset_action_name } | `atom` |  | The name to use for the action which generates a password reset token. If not present it will be generated by prepending the strategy name with `request_password_reset_with_`. |
| [`password_reset_action_name`](#authentication-strategies-password-resettable-password_reset_action_name){: #authentication-strategies-password-resettable-password_reset_action_name } | `atom` |  | The name to use for the action which actually resets the user's password. If not present it will be generated by prepending the strategy name with `password_reset_with_`. |





### Introspection

Target: `AshAuthentication.Strategy.Password.Resettable`




### Introspection

Target: `AshAuthentication.Strategy.Password`



<style type="text/css">.spark-required::after { content: "*"; color: red !important; }</style>