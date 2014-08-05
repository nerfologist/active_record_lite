require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    self.parse_all(DBConnection.instance.execute(<<-SQL, *params.values)
    SELECT #{ self.table_name }.*
    FROM #{ self.table_name }
    WHERE #{ params.keys.map { |k| "#{k.to_s} = ?" }.join(' AND ') }
    SQL
    )
  end
end

class SQLObject
  extend Searchable
end
