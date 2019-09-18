# frozen_string_literal: true

# require File.expand_path('../spec_helper', __FILE__)
require_relative '../ext/pylint/pylint'

describe Pylint do
  let(:pylint) { Pylint.new }
  it 'installed? works based on bin/pylint file' do
    expect(File).to receive(:exist?).with(%r{/bin\/pylint}).and_return(true)
    expect(pylint.installed?).to be_truthy

    expect(File).to receive(:exist?).with(%r{/bin\/pylint}).and_return(false)
    expect(pylint.installed?).to be_falsey
  end

  context 'with path provided' do
    let(:pylint_path) { 'pylint/path' }
    let(:pylint) { Pylint.new(pylint_path) }
    it 'installed? works based on provided path' do
      expect(File).to receive(:exist?).with(pylint_path).and_return(true)
      expect(pylint.installed?).to be_truthy

      expect(File).to receive(:exist?).with(pylint_path).and_return(false)
      expect(pylint.installed?).to be_falsy
    end
  end

  it 'runs pylint without extra arguments' do
    expect(pylint).to receive(:`).with(including('pylint'))
    pylint.run([""])
  end

  it 'runs pylint with 42 file' do
    expect(pylint).to receive(:`).with(including('42.py'))
    pylint.run(["42.py"])
  end

end