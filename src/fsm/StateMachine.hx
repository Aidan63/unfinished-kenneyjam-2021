package fsm;

import haxe.Exception;

class StateMachine<TState : EnumValue, TTrigger : EnumValue>
{
    final configurations : Map<TState, StateRepresentation<TState, TTrigger>>;

    var currentState : TState;

	public function new(_initial)
    {
        configurations = [];
		currentState   = _initial;
	}

    public function getCurrentState()
    {
        return currentState;
    }

    /**
     * Returns the object for configuring a state.
     * @param _state The state to get the configuration for.
     */
    public function config(_state : TState)
    {
        if (configurations.exists(_state))
        {
            return configurations.get(_state);
        }
        else
        {
            final config = new StateRepresentation<TState, TTrigger>();

            configurations.set(_state, config);

            return config;
        }
    }

    /**
     * Perform the specified trigger action.
     * @param _trigger Trigger to perform.
     */
    public function fire(_trigger : TTrigger)
    {
        if (!configurations.exists(currentState))
        {
			throw new Exception('There is no configuration for the current state $currentState');
		}

		final config   = configurations.get(currentState);
        final newState = config.getDestination(_trigger);

		if (newState == null)
        {
			throw new Exception('The current state $currentState does not have a transition for $_trigger');
		}

		config.performExitDueTo(_trigger);

		currentState = newState;

		final config = configurations.get(currentState);
		config.performEntryDueTo(_trigger);
    }

    public function fireWith(_trigger : TTrigger, _data : Any)
    {
        if (!configurations.exists(currentState))
        {
            throw new Exception('There is no configuration for the current state $currentState');
        }

        final config   = configurations.get(currentState);
        final newState = config.getDestination(_trigger);

        if (newState == null)
        {
            throw new Exception('The current state $currentState does not have a transition for $_trigger');
        }

        config.performExitDueTo(_trigger, _data);

        currentState = newState;

        final config = configurations.get(currentState);
        config.performEntryDueTo(_trigger, _data);
    }
}