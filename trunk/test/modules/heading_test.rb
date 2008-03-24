require "#{File.dirname(__FILE__)}/../test_helper"

# Test case for Texier::Modules::Basic class
class HeadingTest < Test::Unit::TestCase
  def setup
    @processor = Texier::Processor.new
    @processor.heading_module.generate_id = false
  end
  
  def test_single_surrounded_heading
    assert_output(
      '<h1>hello world</h1>',
      '####### hello world'
    )
  end
  
  def test_two_surrounded_headings
    assert_output(
      '<h1>level 1</h1><h2>level 2</h2>',
      "####### level 1\n\n###### level 2"
    )
  end
  
  def test_surrounded_heading_with_tail_markers
    assert_output(
      '<h1>hello world</h1>',
      '####### hello world ######'
    )
  end
  
  def test_every_heading_should_be_added_to_the_table_of_contents
    @processor.process("####### level 1\n\n###### level 2")
    
    mod = @processor.heading_module
    
    assert_equal 2, mod.toc.size
    assert_equal 'level 1', mod.toc[0].content
    assert_equal 'level 2', mod.toc[1].content
  end
  
  def test_dynamic_level_balancing
    assert_output('<h1>hello</h1>', '####### hello')
    assert_output('<h1>hello</h1>', '###### hello')
    assert_output('<h1>hello</h1>', '##### hello')
    
    assert_output(
      '<h1>level 1</h1><h2>level 3</h2>',
      "####### level 1\n\n#### level 3"
    )
    
    assert_output(
      '<h1>level 3</h1><h2>level 5</h2>',
      "#### level 3\n\n## level 5"
    )
  end
  
  def test_title
    @processor.process('####### hello world')    
    assert_equal 'hello world', @processor.heading_module.title
  end
  
  def test_title_when_first_heading_contains_inline_element
    @processor.process('####### hello *world*')
    assert_equal 'hello world', @processor.heading_module.title
  end
  
  def test_top
    assert_output '<h1>hello</h1>', '####### hello'
    
    @processor.heading_module.top = 3
    assert_output '<h3>hello</h3>', '####### hello'
  end
  
  def test_more_means_higher
    @processor.heading_module.more_means_higher = true
    assert_output(
      '<h1>level 1</h1><h2>level 2</h2>',
      "####### level 1\n\n###### level 2"
    )
    
    @processor.heading_module.more_means_higher = false    
    assert_output(
      '<h1>level 1</h1><h2>level 2</h2>',
      "###### level 1\n\n####### level 2"
    )
  end
  
  def test_fixed_balancing
    @processor.heading_module.balancing = :fixed
    assert_output '<h4>hello</h4>', '#### hello'
  end
  
  def test_generate_id
    @processor.heading_module.generate_id = true
    assert_output(
      '<h1 id="toc-hello-world">hello world</h1>',
      '####### hello world'
    )
    
    assert_output(
      '<h1 id="toc-level-1">level 1</h1><h2 id="toc-level-2">level 2</h2>',
      "####### level 1\n\n###### level 2"
    )
  end
  
  def test_generated_id_should_be_unique
    @processor.heading_module.generate_id = true
    
    assert_output(
      '<h1 id="toc-hello">hello</h1><h2 id="toc-hello-2">hello</h2>',
      "####### hello\n\n###### hello"
    )
  end
  
  def test_single_underlined_heading
    assert_output(
      '<h1>hello world</h1>',
      "hello world\n######"
    )    
  end
  
  def test_two_underlined_headings
    assert_output(
      '<h1>level 1</h1><h2>level 2</h2>',
      "level 1\n####\n\nlevel 2\n****"
    )
  end

  def test_heading_and_paragraph
    assert_output(
      '<h1>heading</h1><p>hello world</p>',
      "####### heading\n\nhello world"
    )
  end
  
  def test_heading_containing_inline_elements
    assert_output(
      '<h1>hello <em>world</em></h1>',
      '####### hello *world*'
    )
    
    assert_output(
      '<h1>hello <em>world</em></h1>',
      "hello *world*\n####"
    )
  end
end
