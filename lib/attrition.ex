defmodule Attrition do
  @moduledoc """
  """

  @callback data_qa(value :: any()) :: String.t() | {:safe, String.t()}
  @callback data_test(value :: any()) :: String.t() | {:safe, String.t()}

  @data_module Application.get_env(:attrition, :data_module, Attrition.Hide)

  @doc """
  Injects a function definition based on the mix env
  configuration module that is passed.
  No arguments are given.

  The macro defines helper functions once at
  compile-time rather than checking for configuration
  with each function call.

  The functions generated are overrideable.
  """
  @spec __using__([]) :: Macro.t()
  defmacro __using__([]) do
    quote do
      @behaviour Attrition

      @impl Attrition
      def data_qa(value) do
        Attrition.data_module().data_qa(value)
      end

      @impl Attrition
      def data_test(value) do
        Attrition.data_module().data_test(value)
      end

      defoverridable Attrition
    end
  end

  @spec data_module :: atom()
  def data_module, do: @data_module

  defmodule Reveal do
    @moduledoc """
    `Attrition.Reveal` returns the "real" versions of data functions,
    revealing the passed value contents to your markup.

    This functionality is for configured environments only.
    """

    @type safe_string :: {:safe, String.t()}

    @doc """
    Returns :safe HTML string that has interior quotes of interpolated
    value escaped with whitespace padding after value.
    """
    @spec data_qa(String.t()) :: safe_string()
    def data_qa(value), do: {:safe, ~s(data-qa="#{value}" )}

    @doc """
    Returns :safe HTML string that has interior quotes of interpolated
    value escaped with whitespace padding after value.
    """
    @spec data_test(String.t()) :: safe_string()
    def data_test(value), do: {:safe, ~s(data-test="#{value}" )}
  end

  defmodule Hide do
    @moduledoc """
    `Attrition.Hide` returns the noop versions of data functions, essentially
    "hiding" them.

    This is the default functionality for unconfigured or miconfigured
    environments to prevent sensitive data leaking into production
    inadvertantly.
    """

    @doc """
    Returns empty string regardless of argument.
    This is the noop function to be utilized in production environments.
    """
    @spec data_qa(any()) :: String.t()
    def data_qa(_value), do: ""

    @doc """
    Returns empty string regardless of argument.
    This is the noop function to be utilized in production environments.
    """
    @spec data_test(any()) :: String.t()
    def data_test(_value), do: ""
  end
end
