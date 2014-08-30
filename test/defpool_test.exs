defmodule DefpoolTest do
  use ExUnit.Case
  import :meck

  setup do
    new :pooler
    on_exit fn -> unload end
    :ok
  end

  test "defpool define 2 functions" do
    defmodule Ex do
      use Defpool, group: :my_group
      defpool func1(pid, arg1), do: [pid, arg1]

      definitions = Module.definitions_in(__MODULE__)
      assert {:func1, 1} in definitions
      assert {:func1, 2} in definitions
    end
  end

  test "defpool takes pid from pooler group" do
    pid = spawn_link fn ->
      receive do
        _ -> :wait
      end
    end
    expect(:pooler, :take_group_member,
           [{[:my_group], pid}])
    expect(:pooler, :return_group_member,
           [{[:my_group, pid], :ok}])
    defmodule Example do
      use Defpool, group: :my_group
      defpool func1(pid, arg1), do: [pid, arg1]
    end

    assert Example.func1(self, 1) == [self, 1]
    assert Example.func1(1) == [pid, 1]
  end
end
