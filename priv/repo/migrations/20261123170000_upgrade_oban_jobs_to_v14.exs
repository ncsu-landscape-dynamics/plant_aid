defmodule PlantAid.Repo.Migrations.UpgradeObanJobsToV14 do
  use Ecto.Migration

  # Oban 2.24 (mix.lock update, 2026-11-23) expects schema v14:
  #   v13 adds indexes on cancelled_at/discarded_at, v14 adds the 'suspended' job state.
  # The original migration brought the table to v12.
  def up do
    Oban.Migration.up(version: 14)
  end

  def down do
    Oban.Migration.down(version: 12)
  end
end
