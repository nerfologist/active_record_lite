require_relative '03_associatable'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    # black magic! Unreadable code. Debug opts & tabs || (trust me)
    define_method(name) do
      t_opts = self.class.assoc_options[through_name]         # through options
      s_opts = t_opts.model_class.assoc_options[source_name]  # source options
      t_tab  = t_opts.table_name                              # through table
      s_tab  = s_opts.table_name                              # source table
      
      # we want a source class instance, let's parse it and keep one
      s_opts.class_name.constantize.parse_all(
        DBConnection.instance.execute(<<-SQL, send(t_opts.foreign_key))
          SELECT #{s_tab}.*
          FROM   #{s_tab}
          JOIN   #{t_tab}
            ON   #{s_tab}.#{s_opts.primary_key} = #{t_tab}.#{s_opts.foreign_key}
          WHERE  #{t_tab}.id = ?
          LIMIT  1 --there can be only one!
        SQL
      ).first
    end
  end
end
