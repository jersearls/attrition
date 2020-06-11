defmodule Attrition do
  @moduledoc false

  defmacro __using__(_opts) do
    if configured?() do
      quoted_helpers()
    else
      quoted_noop_helpers()
    end
  end

  defp configured? do
    :attrition
    |> Application.get_env(:data_qa)
    |> enabled?
  end

  defp enabled?(:enabled), do: true
  defp enabled?(_), do: false

  defp quoted_noop_helpers do
    quote do
      alias Attrition

      def data_qa(_), do: ""
    end
  end

  defp quoted_helpers do
    quote do
      alias Attrition

      def data_qa(value), do: "data-qa=#{value}"
    end
  end
end
