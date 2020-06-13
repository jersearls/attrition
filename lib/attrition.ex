defmodule Attrition do
  @moduledoc false

  @callback data_qa(value :: any()) :: String.t() | {:safe, String.t()}

  defmacro __using__([]) do
    quoted_data_qa_fn = do_quoted_data_qa_fn()

    quote do
      @behaviour Attrition

      alias Attrition

      @impl Attrition
      unquote(quoted_data_qa_fn)

      defoverridable Attrition
    end
  end

  @spec configured? :: boolean()
  def configured? do
    :attrition
    |> Application.get_env(:data_qa)
    |> enabled?
  end

  @spec data_qa_string(String.t()) :: {:safe, String.t()}
  def data_qa_string(value) when is_binary(value) do
    {:safe, ~s(data-qa="#{value}" )}
  end

  def do_quoted_data_qa_fn() do
    if configured?(), do: quoted_data_qa(), else: quoted_noop_data_qa()
  end

  defp enabled?(:enabled), do: true
  defp enabled?(_), do: false

  defp quoted_noop_data_qa do
    quote do
      def data_qa(_), do: ""
    end
  end

  defp quoted_data_qa do
    quote do
      def data_qa(value), do: Attrition.data_qa_string(value)
    end
  end
end
