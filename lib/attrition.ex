defmodule Attrition do
  @moduledoc """

  Attrition provides the ability to display specific data HTML attributes
  based on the configuration of your mix environment.

  For example, testing and QA can be performed using the data-qa attribute,
  while these attributes are effectively removed from your production markup.
  It accomplishes this through the use of a compile time macro that injects
  overrideable functions.

  If correctly configured and enabled, Attrition provided functions return
  HTML attributes that can be utilized for testing, QA and beyond.

  If no cofiguration is present, Attrition provided functions simply return
  an empty string, thus obfuscating their contents in non-configured envrionments.

  The intentional default redaction of test data and attributes reduces the risk
  of scraping or accidentally exposing sensitive data.

  Currently Attrition only supports the `data-qa` HTML attribute.

  > develop |> attrition |> deploy

  ## Installation

  Attrition can be installed by adding `attrition` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [
      {:attrition, "~> 0.1.0"}
    ]
  end
  ```

  ### Fetch the dependencies

  ```shell
  mix deps.get
  ```

  ## Setup
  Setup for attrition can be accomplished in two easy steps!

  ### 1. Environment Configuration

  In the configuration file for the environment you wish to render the
  data-qa attribute, you must enable data-qa. For example:

  ```elixir
  config :attrition, Attrition
    attrs: [
      data_qa: :enabled
    ]
  ```

  The absence of a configuration, or an invalid configuration will
  result in no attributes displayed.

  ### 2. `Use` Attrition

  Ideally, Attrition is invoked at the view definition through
  the `use` macro. This allows for Attrition provided functions
  to be called in both the view and template without needing to
  provide an alias. This implementation provides a simple,
  light-weight interface without additional cognitive load.


  ```elixir
  # application_web.ex

    def view do
      quote do
        ...

        use Attrition
      end
    end
  ```

  ## Usage

  Once set up and configuration is complete, using Attrition
  provided functions is very straightforward. These functions
  can be invoked at both the view and template.

  Example implementation of the `data_qa` function:
  ```elixir
    <div <%= data_qa "example-count" %>class="example">
  ```

  **NOTE**: In the example above, make note of the spacing. Ensure that
  there is not a space between the closing output capture tag `%>`
  and the next attribute definition. This will ensure the resulting html
  is formatted correctly.

  Example enabled attribute:
  ```html
  <div data-qa="example-count" class="example">
  ```

  Disabled attribute:
  ```html
  <div class="example">
  ```

  ## Testing and Developing with data attributes
  ### Find the data-qa attribute value using Floki
  [Floki](https://hex.pm/packages/floki) is a simple HTML parser that
  can quickly traverse HTML nodes. You can read more about Floki
  [here](https://hexdocs.pm/floki/Floki.html).

  Finding your data-qa attribute with Floki example
  ```elixir
  {:ok, html} = Floki.parse_document(html)

  Floki.find(html, "[data-qa=example-count]")
  ```
  """

  @callback data_qa(value :: any()) :: String.t() | {:safe, String.t()}

  @configuration_module Application.get_env(:attrition, :module, Attrition.NoOp)

  @type safe_string :: {:safe, String.t()}

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
      alias Attrition

      @behaviour Attrition

      @impl Attrition
      def data_qa(value) do
        configuration_module().data_qa(value)
      end

      @impl Attrition
      def data_test(value) do
        configuration_module().data_test(value)
      end

      defoverridable Attrition
    end
  end

  @spec configuration_module :: atom()
  def configuration_module, do: @configuration_module

  @doc """
  Returns :safe HTML string that has interior quotes of interpolated
  value escaped with whitespace padding after value.

  For use in non-production environments.
  """
  @spec data_qa(String.t()) :: safe_string()
  def data_qa(value), do: {:safe, ~s(data-qa="#{value}" )}

  @doc """
  Returns :safe HTML string that has interior quotes of interpolated
  value escaped with whitespace padding after value.

  For use in non-production environments.
  """
  @spec data_test(String.t()) :: safe_string()
  def data_test(value), do: {:safe, ~s(data-test="#{value}" )}

  defmodule NoOp do
    @moduledoc """
    This module returns the noop versions of data functions.

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
