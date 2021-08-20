package fsm;

import haxe.ds.Either;

typedef GenericTransition = () -> Void;

typedef DataTransition = (_data : Any) -> Void;

class StateRepresentation<TState : EnumValue, TTrigger : EnumValue>
{
    final transitions : Map<TTrigger, TState>;

    var entryCallback : Null<Either<GenericTransition, DataTransition>>;

    var exitCallback : Null<Either<GenericTransition, DataTransition>>;

    public function new()
    {
        transitions = [];
    }

    public function onEntry(_func : GenericTransition)
    {
        entryCallback = Left(_func);

        return this;
    }

    public function onEntryWith(_func : DataTransition)
    {
        entryCallback = Right(_func);

        return this;
    }

    public function onExit(_func : GenericTransition)
    {
        exitCallback = Left(_func);

        return this;
    }

    public function onExitWith(_func : DataTransition)
    {
        exitCallback = Right(_func);

        return this;
    }

    public function permit(_trigger : TTrigger, _destination : TState)
    {
        transitions.set(_trigger, _destination);

        return this;
    }

    public function getDestination(_trigger : TTrigger)
    {
        return transitions.get(_trigger);
    }

    public function performExitDueTo(_trigger : TTrigger, _data : Any = null)
    {
        if (exitCallback == null)
        {
            return;
        }

        switch exitCallback
        {
            case Left(v): v();
            case Right(v) if (_data != null): v(_data);
            case _:
        }
    }

    public function performEntryDueTo(_trigger : TTrigger, _data : Any = null)
    {
        if (entryCallback == null)
        {
            return;
        }

        switch entryCallback
        {
            case Left(v): v();
            case Right(v) if (_data != null): v(_data);
            case _:
        }
    }
}