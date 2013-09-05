class CreateMailthreads < ActiveRecord::Migration
  def change
    create_table :mailthreads do |t|

      t.timestamps
    end
  end
end
