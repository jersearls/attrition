defmodule AttritionTest do
  use ExUnit.Case
  use Attrition

  describe "data_qa_string/1" do
    test "with string value, returns data_qa value escaped string" do
      assert Attrition.data_qa_string("test") == {:safe, "data-qa=\"test\""}
    end

    test "with non-string values, raises fn clause errors" do
      assert_raise(FunctionClauseError, fn ->
        Attrition.data_qa_string(1)
      end)

      assert_raise(FunctionClauseError, fn ->
        Attrition.data_qa_string(:one)
      end)
    end
  end

  describe "configured/0" do
    setup do
      on_exit(fn -> data_qa_disabled() end)
    end

    test "with no configuration, returns false" do
      refute Attrition.configured?()
    end

    test "with configuration, returns true" do
      data_qa_enabled()
      assert Attrition.configured?()
    end
  end

  describe "do_quoted_data_qa_fn" do
    setup do
      on_exit(fn -> data_qa_disabled() end)
    end

    test "with no data_qa enabled, returns quoted_noop_data_qa/0 AST" do
      assert Attrition.do_quoted_data_qa_fn() |> Macro.to_string() =~ "def(data_qa(_)"
    end

    test "with data_qa enabled, returns quoted_data_qa/0 AST" do
      data_qa_enabled()

      assert Attrition.do_quoted_data_qa_fn() |> Macro.to_string() =~ "def(data_qa(value)"
    end
  end

  defp data_qa_enabled do
    Application.put_env(:attrition, :data_qa, :enabled)
  end

  defp data_qa_disabled do
    Application.delete_env(:attrition, :data_qa)
  end
end
