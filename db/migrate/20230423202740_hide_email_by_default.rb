class HideEmailByDefault < ActiveRecord::Migration[7.0]
  def up
    rename_column :users, :hide_email, :public_email
    execute <<~SQL
      UPDATE users SET public_email = NOT public_email;
    SQL
    change_column_default :users, :public_email, false
  end

  def down
    change_column_default :users, :public_email, true
    execute <<~SQL
      UPDATE users SET public_email = NOT public_email;
    SQL
    rename_column :users, :public_email, :hide_email
  end
end
