require_relative 'db_connection'
# require_relative 'sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map {|key| "#{key} = ?"}.join(" AND ")

    vals = params.values

    instances = DBConnection.execute(<<-SQL, vals)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    parse_all(instances)
  end
end
