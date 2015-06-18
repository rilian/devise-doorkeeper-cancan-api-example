# https://gist.github.com/rilian/e89d9dbc096f56ebcb1d
#
# Custom rspec matcher for testing CanCan abilities.
# Originally inspired by https://github.com/ryanb/cancan/wiki/Testing-Abilities
#
# Usage:
# expect.to have_abilities(:create).on(Post.new)
# expect.to have_abilities([:read, :update].on(post)
# expect.to have_abilities({manage: false, destroy: true}.on(post)
# expect.to have_abilities({create: false}.on(Post.new)
# expect.to not_have_abilities(:update.on(post)
# expect.to not_have_abilities([:update, :destroy].on(post)
#
# WARNING: never use "should_not have_abilities" or you may get false positives due to
# whitelisting/blacklisting issues. Use "should not_have_abilities" instead.
RSpec::Matchers.define :have_abilities do |actions|
  include HaveAbilitiesMixin
  chain :on do |obj|
    @obj = obj
  end

  match do |ability|
    verify_ability_type(ability)
    @expected_hash = build_expected_hash(actions, default_expectation: true)
    @actual_hash = {}
    @expected_hash.each do |action, _|
      @actual_hash[action] = ability.can?(action, @obj)
    end
    @actual_hash == @expected_hash
  end

  description do
    obj_name = @obj.class.name
    obj_name = @obj.to_s.capitalize if [Class, Module, Symbol].include?(@obj.class)
    "have abilities #{@expected_hash.keys.join(', ')} on #{obj_name}"
  end

  failure_message do
    obj_name = @obj.class.name
    obj_name = @obj.to_s.capitalize if [Class, Module, Symbol].include?(@obj.class)
    "expected user to have abilities: #{@expected_hash} for #{obj_name}, but got #{@actual_hash}"
  end
end

RSpec::Matchers.define :not_have_abilities do |actions|
  include HaveAbilitiesMixin
  chain :on do |obj|
    @obj = obj
  end

  match do |ability|
    verify_ability_type(ability)
    if actions.is_a?(Hash)
      raise ArgumentError, 'You cannot pass a hash to not_have_abilities. Use have_abilities instead.'
    end
    @expected_hash = build_expected_hash(actions, default_expectation: false)
    @actual_hash = {}
    @expected_hash.each do |action, _|
      @actual_hash[action] = ability.can?(action, @obj)
    end
    @actual_hash == @expected_hash
  end

  description do
    obj_name = @obj.class.name
    obj_name = @obj.to_s.capitalize if [Class, Module, Symbol].include?(@obj.class)
    "not have abilities #{@expected_hash.keys.join(', ')} on #{obj_name}" if @expected_hash.present?
  end

  failure_message do
    obj_name = @obj.class.name
    obj_name = @obj.to_s.capitalize if [Class, Module, Symbol].include?(@obj.class)
    "expected user NOT to have abilities #{@expected_hash.keys.join(', ')} for #{obj_name}, but got #{@actual_hash}"
  end
end

module HaveAbilitiesMixin
  def build_expected_hash(actions, default_expectation:)
    return actions if actions.is_a?(Hash)
    expected_hash = {}
    if actions.is_a?(Array)
      # If given an array like [:create, read] build a hash like:
      # {create: default_expectation, read: default_expectation}
      actions.each { |action| expected_hash[action] = default_expectation }
    elsif actions.is_a?(Symbol)
      # Build a hash if it's just a symbol.
      expected_hash = { actions => default_expectation }
    end
    expected_hash
  end

  def verify_ability_type(ability)
    return if ability.class.ancestors.include?(CanCan::Ability)
    raise TypeError, "subject must mixin CanCan::Ability, got a #{ability.class.name} class."
  end
end
