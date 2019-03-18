var MCPreview = {
	addButtons: function() {
		var target = document.querySelector(".staging-update-preview .staging-preview-options");

		var buttonGroup = document.createElement('div');
		buttonGroup.classList.add("staging-preview-item-resize");
		buttonGroup.innerHTML = '<a href="#" class="resizeMobile">mobile</a><a href="#" class="resizeTablet">tablet</a><a href="#" class="resizeDefault">default</a>';

		target.appendChild(buttonGroup);

		var mobileButton = document.querySelector(".staging-update-preview .resizeMobile");
		var tabletButton = document.querySelector(".staging-update-preview .resizeTablet");
		var desktopButton = document.querySelector(".staging-update-preview .resizeDefault");
		mobileButton.addEventListener('click', function(){ MCPreview.addDynamicClass('mobile'); }, false);
		tabletButton.addEventListener('click', function(){ MCPreview.addDynamicClass('tablet'); }, false);
		desktopButton.addEventListener('click', function(){ MCPreview.addDynamicClass(''); }, false);

	},

	addDynamicClass: function(className) {
		var contentDynamic = document.querySelector(".staging-preview-content-dynamic");
		contentDynamic.classList.remove('mobile');
		contentDynamic.classList.remove('tablet');
		contentDynamic.classList.add(className);
	}

}

MCPreview.addButtons();