TODO: refactor
```ruby
class Adapter
  def get_table_name
    raise "not implemented"
  end
end

class PostgresAdapter < Adapter
  def get_table_name

  end
end

class MysqlAdapter < Adapter
  def get_table_name

  end
end


class OracleAdapter < Adapter
  def get_table_name

  end
end
```
