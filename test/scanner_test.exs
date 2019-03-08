defmodule ScannerTest do
  use ExUnit.Case, async: true

  alias Exmoji.Scanner

  @case_exact         "🚀"
  @case_multi         "\u{0023}\u{FE0F}\u{20E3}"
  @case_variant       "flying on my 🚀 to visit the 👾 people."
  @case_multivariant  "first a \u{0023}\u{FE0F}\u{20E3} then a 🚀"
  @case_duplicates    "flying my 🚀 to visit the 👾 people who have their own 🚀 omg!"
  @case_none          "i like turtles"

  #
  # #scan
  #
  test ".scan - should find the proper EmojiChar from a single string char" do
    results = Scanner.scan(@case_exact)
    assert Enum.count(results) == 1
    assert Enum.at(results,0).__struct__ == Exmoji.EmojiChar
    assert Enum.at(results,0).name == "ROCKET"
  end

  test ".scan - should find the proper EmojiChar from a variant encoded char" do
    results = Scanner.scan(@case_multi)
    assert Enum.count(results) == 1
    assert Enum.at(results,0).name == "HASH KEY"
  end

  test ".scan - should match multiple chars from within a string" do
    results = Scanner.scan(@case_variant)
    assert Enum.count(results) == 2
  end

  test ".scan - should return multiple matches in proper order" do
    results = Scanner.scan(@case_variant)
    assert Enum.at(results,0).name == "ROCKET"
    assert Enum.at(results,1).name == "ALIEN MONSTER"
  end

  test ".scan - should return multiple matches in proper order for variants" do
    results = Scanner.scan(@case_multivariant)
    assert Enum.count(results) == 2
    assert Enum.at(results,0).name == "HASH KEY"
    assert Enum.at(results,1).name == "ROCKET"
  end

  test ".scan - should return multiple matches including duplicates" do
    results = Scanner.scan(@case_duplicates)
    assert Enum.count(results) == 3
    assert Enum.at(results,0).name == "ROCKET"
    assert Enum.at(results,1).name == "ALIEN MONSTER"
    assert Enum.at(results,2).name == "ROCKET"
  end

  test ".scan - returns and empty list if nothing is found" do
    assert Scanner.scan(@case_none) == []
  end

  test ".strip" do
    assert Scanner.strip_emoji(@case_exact) == ""
    assert Scanner.strip_emoji(@case_multi) == ""
    assert Scanner.strip_emoji(@case_variant) == "flying on my  to visit the  people."
    assert Scanner.strip_emoji(@case_multivariant) == "first a  then a "
    assert Scanner.strip_emoji(@case_duplicates) == "flying my  to visit the  people who have their own  omg!"
    assert Scanner.strip_emoji(@case_none) == "i like turtles"

    foreign1 = "طويلبون فيلادلفيا"
    assert Scanner.strip_emoji(foreign1) == foreign1
  end
end
