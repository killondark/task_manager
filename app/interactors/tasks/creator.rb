# frozen_string_literal: true

module Tasks
  class Creator < ApplicationInteractor
    option :task_params, reader: :private, optional: false

    class Contract < BaseContract
      params do
        required(:task_params).value(:hash)
      end
    end

    def call
      yield validate_contract(Contract, { task_params: task_params })

      task = Task.new(task_params)
      if task.save
        Success(task)
      else
        Failure(task)
      end
    end
  end
end
