/**
 * Created by user on 4/14/2017.
 */

(function () {
    var app = angular.module('ap-slider');
    //TODO: move all the DOM manipulation in this controller to a directive
    app.controller('apSliderCtrl', ['$scope', 'jProductGroup1Data', '$timeout',
        function ($scope, jProductGroup1Data, $timeout) {
            $scope.productsGroup1_title = "Customer View for AussieProducts.com";
            $scope.apcCurrentProducts = jProductGroup1Data.Row1Group1; // will change to different product group later
            $scope.apcRow1Group2 = jProductGroup1Data.Row1Group2;
            $scope.apcRow1Group3 = jProductGroup1Data.Row1Group3;
            $scope.apcRow1Group4 = jProductGroup1Data.Row1Group4;
            $scope.activeArea = -1;
            $scope.repetitionAmount = [0, 1, 2];
            $scope.incrementLeft = false;

            var pgPositionTracker = [
                {pos: "initialState"},
                {pos: "right"},
                {pos: "right"},
                {pos: "right"}
            ];

            //-- public functions:
            $scope.updateActiveArea = function (index) {
                switch (index) {
                    case 0:
                        pgPositionTracker[0].pos = "left";
                        if (pgPositionTracker[1].pos === "left" ||
                            pgPositionTracker[2].pos === "left") {
                            removeIncrementLeft();
                            pgPositionTracker[1].pos = "right";
                            pgPositionTracker[2].pos = "right";
                        } else if (pgPositionTracker[1].pos === "center") {
                            pgPositionTracker[1].pos = "right";
                        }

                        // The MOST critical aspect of this function
                        $scope.activeArea = -1;
                        break;
                    case 1:
                        pgPositionTracker[1].pos = "center";
                        if (pgPositionTracker[2].pos === "left") {
                            removeIncrementLeft();
                            pgPositionTracker[2].pos = "right";
                        }

                        // The MOST critical aspect of this function
                        $scope.activeArea = 0;
                        break;
                    case 2:
                        pgPositionTracker[2].pos = "center";
                        if(pgPositionTracker[1].pos === "center") {
                            pgPositionTracker[2].pos = "left";
                        }
                        // The MOST critical aspect of this function
                        $scope.activeArea = 1;
                        break;
                    case 3:
                        pgPositionTracker[3].pos = "left";

                        // The MOST critical aspect of this function
                        $scope.activeArea = 2;
                        break;
                }

                domUpP1(index);

                // console.log("jha - activeArea = " + $scope.activeArea + ", incrementLeft = " + $scope.incrementLeft);
            };

            $scope.indicatorCheck = function () {
                var aa = $scope.activeArea;
                if (aa === -1) {
                    return 0;
                } else if (aa === 0) {
                    return 1;
                } else if (aa === 1) {
                    return 2;
                } else if (aa === 2) {
                    return 3;
                }
            };

            // private functions
            var removeIncrementLeft = function () {
                angular.element('.product-group.increment-left').each(function (i) {
                    // console.log(this);
                    angular.element(this).removeClass('increment-left');
                    pgPositionTracker[i].pos = "right";
                });
            };

            var domUpP1 = function (index) {
                // give the DOM a moment to update
                $timeout(function () {
                    var pgElem = ".product-group" + (index - 1),
                        pgSelector = angular.element(pgElem),
                        pgActive = pgSelector.hasClass('active');

                    if (pgActive) {
                        if (pgElem !== '.product-group2') {
                            //'.product-group2' should never increment-left because it's last
                            // e.g. group0, group1, group2
                            pgSelector.addClass('increment-left');
                        }
                    }
                }, 10);
            };
        }
    ]);
})();

//