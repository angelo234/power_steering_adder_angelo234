angular.module('beamng.apps')
.directive('powerSteeringAdderAngelo234', [function () {
return {
templateUrl: '/ui/modules/apps/power_steering_adder_angelo234/app.html',
replace: true,
restrict: 'EA',
link: function (scope, element, attrs) {
	var settings_file_path = "settings/power_steering_adder_angelo234/settings.json";
	
	// The current overlay screen the user is on (default: null)
	scope.overlayScreen = null;	
	scope.add_power_steering = false;
	
	// Read last UI state file to return to last state
	bngApi.engineLua("jsonReadFile('" + settings_file_path + "')", function(data) {
		if(data !== undefined){
			scope.add_power_steering = data.add_power_steering;
			
			bngApi.engineLua('scripts_power__steering__adder__angelo234_extension.setAddPowerSteeringAutomatically(' + scope.add_power_steering + ')');
		}
	});	
	
	scope.onButtonClicked = function () {
		bngApi.engineLua('scripts_power__steering__adder__angelo234_extension.addPowerSteering()');
	};
	
	scope.onCheckboxClicked = function () {
		bngApi.engineLua('scripts_power__steering__adder__angelo234_extension.setAddPowerSteeringAutomatically(' + scope.add_power_steering + ')');
	
		// Save current state to file
		var data = {}
		data.add_power_steering = scope.add_power_steering;	
		data = JSON.stringify(data);
	
		bngApi.engineLua("writeFile('" + settings_file_path + "','" + data + "', true)");
	};
},
};
}]);