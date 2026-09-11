# frozen_string_literal: true

class ApplicationInteractor
  include Dry::Monads[:result, :do, :maybe, :try]
  include Dry::Monads::Do.for(:call)
  extend Dry::Initializer

  class BaseContract < Dry::Validation::Contract; end

  def self.call(params = {})
    new(**params).call
  end

  def call
    Success()
  end

  private

  def validate_contract(contract, params, **contract_options)
    result = contract.new(**contract_options).call(params)
    if result.success?
      Success(result.to_h)
    else
      Failure(result.errors.to_h)
    end
  end

  def process_error
    yield
  rescue Dry::Monads::Do::Halt => e
    e.result
  rescue StandardError => e
    Rails.logger.error(e)
    raise e if Rails.env.test?

    Failure(e)
  end
end
