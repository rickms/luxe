

class RunTests extends luxe.Game {

    override function config( config:luxe.GameConfig ) {

        return config;

    } //config

    override function ready() {

            //run tests
        new transform.Transforms();

        Luxe.shutdown();

    } //ready

} //RunTests