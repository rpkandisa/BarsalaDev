({

    afterRender : function(component) {
        this.superAfterRender();
        // debugger;

        // console.log(component.isRendered()); // is evaluating to true
		// console.log($); // causes error overlay because $ is undefined
		
		

     },

     rerender : function(cmp, helper){
        this.superRerender();
       /*$("#owlheadslider").owlCarousel({
			loop:true,
			margin:0,
			nav:true,
			responsive:{
				0:{
					items:1
				}
			}
		}); */
		
		setTimeout(function () {
			 //debugger;
            let imgCnt = $('#owlcityslider').attr('data-image-count');
            let loopVar = true;
            if(imgCnt == undefined || imgCnt == null){
                imgCnt = 1;
            }else{
                imgCnt = parseInt(imgCnt);
            }
            if(imgCnt == 1){
                loopVar = false;
            }else{
                imgCnt = 2; // to display 2 images at a time in window
            }
			$('#owlcityslider').owlCarousel({
				loop:loopVar,
                responsiveClass:true,
				margin:10,
                nav:true,
				responsive:{
					0:{
						items:imgCnt
					}
				}
			});
            if(imgCnt == 1){
                $('#owlcityslider').find('img').css({'width' : '350px'});
            }
		}, 300);
        
         $('.faqList li a').click(function(){
				$('.faqList li a').removeClass("active")
				$(this).addClass("active")
				$(".faqCont").slideUp();
				$(this).next(".faqCont").slideDown();
			});

			$('.tab li a').click(function(){
				var tabCont = "#" + $(this).attr("rel")
				$('.tab li a').removeClass("active")
				$(this).addClass("active")
				$(".tabCont").hide();
				$(tabCont).show();
			});
         
		/*$("#owlheadslider").owlCarousel({
			loop:true,
			margin:0,
			nav:true,
			responsive:{
				0:{
					items:1
				}
			}
		});
		$('.homeBotSlider .owl-carousel').owlCarousel({
				loop:true,
				margin:10,
				nav:false,
				responsive:{
					0:{
					items:1.5
					}
				}
			});

			


			
		setTimeout(function () {
			$('#owlcityslider').owlCarousel({
				loop:true,
				margin:10,
				nav:false,
				responsive:{
					0:{
					items:1.5
					}
				}
			});
		}, 300);
        
*/
     }

})