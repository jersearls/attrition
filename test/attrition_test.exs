defmodule AttritionTest do
  use ExUnit.Case
  alias Attrition

  describe "data_module/0" do
    test "without a configured env, returns default Hide module" do
      assert Attrition.data_module() == Attrition.Hide
    end
  end

  defmodule RevealTest do
    alias Attrition.Reveal
    use ExUnit.Case

    describe "data_qa/1" do
      test "with string, returns safe tuple with escaped string" do
        test_value = "baz-qux"
        assert {:safe, escaped_string} = Reveal.data_qa(test_value)
        assert EEx.eval_string(escaped_string) == "data-qa=\"#{test_value}\" "
      end

      test "with non-string values, raises fn clause errors" do
        assert_raise(FunctionClauseError, fn ->
          Reveal.data_qa(1)
        end)

        assert_raise(FunctionClauseError, fn ->
          Reveal.data_qa(:one)
        end)
      end
    end

    describe "data_test/1" do
      test "with string, returns safe tuple with escaped string" do
        test_value = "baz-qux"
        assert {:safe, escaped_string} = Reveal.data_test(test_value)
        assert EEx.eval_string(escaped_string) == "data-test=\"#{test_value}\" "
      end

      test "with non-string values, raises fn clause errors" do
        assert_raise(FunctionClauseError, fn ->
          Reveal.data_test(1)
        end)

        assert_raise(FunctionClauseError, fn ->
          Reveal.data_test(:one)
        end)
      end
    end
  end

  defmodule HideTest do
    alias Attrition.Hide
    use ExUnit.Case

    describe "data_qa/1" do
      test "with any value, returns empty string" do
        assert Hide.data_qa("test") == ""
        assert Hide.data_qa(1) == ""
        assert Hide.data_qa(:test) == ""
      end
    end

    describe "data_test/1" do
      test "with any value, returns empty string" do
        assert Hide.data_test("test") == ""
        assert Hide.data_test(1) == ""
        assert Hide.data_test(:test) == ""
      end
    end
  end
end
