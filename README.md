defpool
=======

This project aims to give a flexible way of define functions that need a pid to do some work. For example:

```elixir
defmodule Example do
  def do_something(pid, arg1, arg2) do
    #...
  end
end
```

What happens if you want to call do_something with any pid from a pool of pids you own?

That's where defpool is useful!

```elixir
defmodule Example do
  use Defpool, group: :pool_group
  defpool do_something(pid, arg1, arg2) do
    #...
  end
end
```

The generated code would be something like this:

defmodule Example do
  def do_something(pid, arg1, arg2) do
    #... original code
  end
  def do_something(arg1, arg2) do
    pid = :pooler.take_group_member(:pool_group)
    result = do_something(pid, arg1, arg2)
    :ok = :pooler.return_group_member(:pool_group, pid)
    result
  end
end

As you can see do_something will grab a pid from `pool_group` and call the defined function.
The group option should be defined while calling `use Defpool` or :default will be used.

It's important to notice that `defpool` will expect the first argument to be the pid.
