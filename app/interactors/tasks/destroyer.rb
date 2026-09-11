# frozen_string_literal: true

module Tasks
  class Destroyer < ApplicationInteractor
    option :task, reader: :private, optional: false

    class Contract < BaseContract
      params do
        required(:task).filled(type?: Task)
      end
    end

    def call
      yield validate_contract(Contract, { task: task })

      task.destroy
      Success(task)
    end
  end
end
