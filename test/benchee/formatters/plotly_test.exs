defmodule Benchee.Formatters.PlotlyJSTest do
  use ExUnit.Case
  alias Benchee.Formatters.PlotlyJS

  @filename "my.html"
  @expected_filename "my_some_input.html"
  @sample_suite %{
                  config: %{plotly_js: %{file: @filename}},
                  statistics: %{
                    "Some Input" => %{
                      "My Job" => %{
                        average: 200.0,
                        ips: 5000.0,
                        std_dev: 20,
                        std_dev_ratio: 0.1,
                        std_dev_ips: 500,
                        median: 190.0
                      }
                    }
                  },
                  run_times: %{"Some Input" => %{"My Job" => [190, 200, 210]}}
                }
  test ".format returns an HTML-ish string" do
    %{"Some Input" => html} = PlotlyJS.format @sample_suite
    assert html =~ ~r/<html>.+<script>.+<\/html>/si
  end

  test ".format has the important suite data in the html result" do
    %{"Some Input" => html} = PlotlyJS.format @sample_suite

    assert_includes html, ["[190,200,210]", "\"average\":200.0",
                           "\"median\":190.0","\"ips\":5.0e3", "My Job"]

  end

  test ".format produces the right JSON data without the input level" do
    %{"Some Input" => html} = PlotlyJS.format @sample_suite

    assert html =~ "{\"statistics\":{\"My Job\""
  end

  defp assert_includes(html, expected_contents) do
    Enum.each expected_contents, fn(expected_content) ->
      assert html =~ expected_content
    end
  end

  test ".output returns the suite again unchanged" do
    try do
      return = Benchee.Formatters.PlotlyJS.output(@sample_suite)
      assert return == @sample_suite
      assert File.exists? @expected_filename
      content = File.read! @expected_filename
      assert_includes content, ["My Job", "average"]
    after
      if File.exists?(@expected_filename), do: File.rm! @expected_filename
    end
  end
end
