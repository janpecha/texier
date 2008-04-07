require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::Phrase class
class Texier::Modules::PhraseTest < Test::Unit::TestCase
  def setup
    @processor = Texier::Processor.new
  end
  
  def test_em
    assert_output '<p><em>hello world</em></p>', '*hello world*'
    assert_output '<p><em>hello world</em></p>', '//hello world//'
  end

  def test_em_and_plain_text
    assert_output '<p>hello <em>world</em> again</p>', 'hello *world* again'
  end
  
  def test_em_with_modifier
    assert_output(
      '<p><em class="foo">hello world</em></p>',
      '*hello world .[foo]*'
    )
  end

  def test_strong
    assert_output '<p><strong>hello world</strong></p>', '**hello world**'
  end

  def test_strong_em
    assert_output(
      '<p><strong><em>hello</em></strong></p>',
      '***hello***'
    )
  end

  def test_quote
    assert_output '<p><q>hello world</q></p>', '>>hello world<<'
  end
  
  def test_quote_with_cite
    assert_output(
      '<p><q cite="http://metatribe.org">hello world</q></p>',
      '>>hello world<<:http://metatribe.org'
    )
  end
  
  def test_code
    assert_output '<p><code>def test_code</code></p>', '`def test_code`'
  end
  
  def test_content_of_code_should_be_escaped
    assert_output '<p><code>if x &lt; y</code></p>', '`if x < y`'
  end
  
  def test_ins
    @processor.allowed['phrase/ins'] = true
    assert_output '<p><ins>hello world</ins></p>', '++hello world++'
  end
  
  def test_ins_should_be_disabled_by_default
    assert_output '<p>++hello world++</p>', '++hello world++'
  end

  def test_del
    @processor.allowed['phrase/del'] = true
    assert_output '<p><del>hello world</del></p>', '--hello world--'
  end

  def test_del_should_be_disabled_by_default
    assert_output '<p>--hello world--</p>', '--hello world--'
  end
  
  def test_sup
    @processor.allowed['phrase/sup'] = true
    assert_output '<p>x<sup>2</sup></p>', 'x^^2^^'

    assert_output '<p>x<sup>2</sup></p>', 'x^2'
    assert_output '<p>x ^2</p>', 'x ^2'
  end

  def test_sup_should_be_disabled_by_default
    assert_output '<p>x^^2^^</p>', 'x^^2^^'
  end

  def test_sub
    @processor.allowed['phrase/sub'] = true
    assert_output '<p>x<sub>2</sub></p>', 'x__2__'
    
    assert_output '<p>x<sub>2</sub></p>', 'x_2'
  end

  def test_sub_should_be_disabled_by_default
    assert_output '<p>x__2__</p>', 'x__2__'
  end
  
  def test_alternative_sup_and_sub_with_negative_number
    assert_output "<p>x<sup>\xE2\x88\x922</sup></p>", 'x^-2'
    assert_output "<p>x<sub>\xE2\x88\x922</sub></p>", 'x_-2'
  end
  
  def test_cite
    @processor.allowed['phrase/cite'] = true
    assert_output '<p><cite>hello world</cite></p>', '~~hello world~~'
  end

  def test_cite_should_be_disabled_by_default
    assert_output '<p>~~hello world~~</p>', '~~hello world~~'
  end
  
  def test_acronym
    assert_output(
      '<p><acronym title="don\'t repeat yourself">DRY</acronym></p>',
      'DRY((don\'t repeat yourself))'
    )
    
    assert_output(
      '<p><acronym title="and others">et. al</acronym></p>',
      '"et. al"((and others))'
    )
  end
  
  def test_acronym_should_be_recognized_only_if_it_has_at_least_two_letters
    assert_output '<p>F((Foo))</p>', 'F((Foo))'
  end
  
  def test_phrase_with_link
    assert_output(
      '<p><a href="http://metatribe.org"><em>hello world</em></a></p>',
      '*hello world*:http://metatribe.org'
    )
    
    assert_output(
      '<p><a href="http://metatribe.org/weird-stuff?"><em>hello world</em></a></p>',
      '*hello world*:[http://metatribe.org/weird-stuff?]'
    )
  end
  
  def test_quick_link
    assert_output(
      '<p><a href="http://metatribe.org">hello</a></p>',
      'hello:http://metatribe.org'
    )
  end
  
  def test_span_with_link
    assert_output(
      '<p><a href="http://metatribe.org">hello</a></p>',
      '"hello":http://metatribe.org'
    )
    
    assert_output(
      '<p><a href="http://metatribe.org">hello</a></p>',
      '~hello~:http://metatribe.org'
    )
  end
  
  def test_span_with_modifier
    assert_output(
      '<p><span class="foo">hello</span></p>',
      '"hello .[foo]"'
    )
    
    assert_output(
      '<p><span class="foo">hello</span></p>',
      '~hello .[foo]~'
    )
  end
  
  def test_span_with_link_and_modifier
    assert_output(
      '<p><a class="foo" href="http://metatribe.org">hello</a></p>',
      '"hello .[foo]":http://metatribe.org'
    )
    
    assert_output(
      '<p><a class="foo" href="http://metatribe.org">hello</a></p>',
      '~hello .[foo]~:http://metatribe.org'
    )
  end
  
  def test_span_without_link_or_modifier_should_be_ignored
    assert_output '<p>"hello"</p>', '"hello"'
    assert_output '<p>~hello~</p>', '~hello~'
  end
  
  def test_notexy
    assert_output '<p>*hello*</p>', "''*hello*''"
    assert_output '<p>&lt;em&gt;hello&lt;/em&gt;</p>', "''<em>hello</em>''"
  end
  
  def test_links_allowed_set_to_false
    @processor.phrase_module.links_allowed = false
    
    # TODO: Not sure if this is desired behavior. Check how Texy! does it.
    
    assert_output(
      '<p><em>hello</em>:<a href="http://metatribe.org">http://metatribe.org</a></p>', 
      '*hello*:http://metatribe.org'
    )
  end
  
  def test_when_links_are_disabled_span_with_link_and_no_modifier_should_be_ignored
    @processor.phrase_module.links_allowed = false
    
    # TODO: Not sure if this is desired behavior. Check how Texy! does it.

    assert_output(
      '<p>"hello":<a href="http://metatribe.org">http://metatribe.org</a></p>',
      '"hello":http://metatribe.org'
    )
  end
end