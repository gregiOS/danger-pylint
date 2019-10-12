# frozen_string_literal: true

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

  it 'runs pylint with rcfile' do
    expect(pylint).to receive(:`).with(including(Dir.pwd + '/.pylintrc'))
    pylint.run(["42.py"], '.pylintrc')
  end

  it 'runs pylint with rcfile' do
    expect(pylint).to receive(:`).with(including(Dir.pwd + '/.pylintrc'))
    pylint.run(["42.py"], Dir.pwd + '/.pylintrc')
  end

  it 'runs pylint without files' do
    expect(pylint).to receive(:`).with(including('lint'))
    pylint.run()
  end

end