defmodule Defpool do
  @moduledoc """
  This module adds defpool to define functions with a
  lower arity for each function so:

  YourModule.func1(pid, arg1, arg2, arg3) ->
  YourModule.func2(arg1, arg2, arg3) that calls the previous function
  with a pid from the pool
  """

  defmacro __using__(opts) do
    group = Keyword.get(opts, :group, :default)
    quote do
      import Defpool
      Module.put_attribute __MODULE__, :defpool_group, unquote(group)
    end
  end

  defmacro defpool(args, do: block) do
    {{name, _, args}, guards} = extract_guards(args)
    [_pid_arg | other_args] = args
    quote bind_quoted: [
      guards: Macro.escape(guards, unquote: true),
      block: Macro.escape(block, unquote: true),
      args: Macro.escape(args, unquote: true),
      other_args: Macro.escape(other_args, unquote: true),
      name: name
    ] do
      if guards == [] do
        def unquote(name)(unquote_splicing(args)), do: unquote(block)
      else
        def unquote(name)(unquote_splicing(args)) when unquote(hd(guards)) do
          unquote(block)
        end
      end
      def unquote(name)(unquote_splicing(other_args)) do
        case :pooler.take_group_member(@defpool_group) do
          pid when is_pid(pid) ->
            :pooler.take_group_member(@defpool_group)
            result = unquote(name)(pid, unquote_splicing(other_args))
            :ok = :pooler.return_group_member(@defpool_group, pid)
            result
          error -> error
        end
      end
    end
  end

  defp extract_guards({:when, _, [left, right]}), do: {left, extract_or_guards(right)}
  defp extract_guards(else_), do: {else_, []}
  defp extract_or_guards({:when, _, [left, right]}), do: [left|extract_or_guards(right)]
  defp extract_or_guards(term), do: [term]
end
