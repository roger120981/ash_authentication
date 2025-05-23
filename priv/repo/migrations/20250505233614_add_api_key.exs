defmodule Example.Repo.Migrations.AddApiKey do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:api_keys, primary_key: false) do
      add(:id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true)
      add(:api_key_hash, :binary, null: false)

      add(:created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
      )

      add(:updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
      )

      add(
        :user_id,
        references(:user,
          column: :id,
          name: "api_keys_user_id_fkey",
          type: :uuid,
          prefix: "public"
        ),
        primary_key: true,
        null: false
      )
    end
  end

  def down do
    drop(constraint(:api_keys, "api_keys_user_id_fkey"))

    drop(table(:api_keys))
  end
end
