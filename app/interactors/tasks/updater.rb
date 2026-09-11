# frozen_string_literal: true

module Tasks
  class Updater < ApplicationInteractor
    option :task, reader: :private, optional: false
    option :task_params, reader: :private, optional: false

    class Contract < BaseContract
      params do
        required(:task).filled(type?: Task)
        required(:task_params).value(:hash)
      end
    end

    def call
      yield validate_contract(Contract, { task: task, task_params: task_params })

      if task.update(task_params)
        Success(task)
      else
        Failure(task)
      end
    end
  end
end
