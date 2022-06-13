(function(storyContent) {

    // Create ink story from the content using inkjs
    var story = new inkjs.Story(storyContent);

    // Global tags - those at the top of the ink file
    // We support:
    //  # theme: dark
    //  # author: Your Name
    var globalTags = story.globalTags;
    if( globalTags ) {
        for(var i=0; i<story.globalTags.length; i++) {
            var globalTag = story.globalTags[i];
            var splitTag = splitPropertyTag(globalTag);
            
            // THEME: dark
            if( splitTag && splitTag.property == "theme" ) {
                document.body.classList.add(splitTag.val);
            }
            
            // author: Your Name
            else if( splitTag && splitTag.property == "author" ) {
                var byline = document.querySelector('.byline');
                byline.innerHTML = "by "+splitTag.val;
            }
        }
    }

    var storyContainer = document.querySelector('#story');
    var outerScrollContainer = document.querySelector('.outerContainer');

    // Kick off the start of the story!
    continueStory(true);

    // Main story processing function. Each time this is called it generates
    // all the next content up as far as the next set of choices.
    function continueStory(firstTime) {

        var paragraphIndex = 0;
        var delay = 0.0;
        
        // Don't over-scroll past new content
        var previousBottomEdge = firstTime ? 0 : contentBottomEdgeY();

        // Generate story text - loop through available content
        while(story.canContinue) {

            // Get ink to generate the next paragraph
            var paragraphText = story.Continue();
            var tags = story.currentTags;
            
            // Any special tags included with this line
            var customClasses = [];
            for(var i=0; i<tags.length; i++) {
                var tag = tags[i];

                // Detect tags of the form "X: Y". Currently used for IMAGE and CLASS but could be
                // customised to be used for other things too.
                var splitTag = splitPropertyTag(tag);

                // IMAGE: src
                if( splitTag && splitTag.property == "IMAGE" ) {
                    var imageElement = document.createElement('img');
                    imageElement.src = splitTag.val;
                    storyContainer.appendChild(imageElement);

                    showAfter(delay, imageElement);
                    delay += 200.0;
                }

                // CLASS: className
                else if( splitTag && splitTag.property == "CLASS" ) {
                    customClasses.push(splitTag.val);
                }
                
                // Custom
                // SET_BG: image.png
                else if( splitTag && splitTag.property == "SET_BG"){
                    setMapImage(splitTag.val);
                }

                // Custom
                // BRIDGE_CROSSED: bridge_id
                else if( splitTag && splitTag.property == "BRIDGE_CROSSED"){
                    showBridge(splitTag.val);
                }

                // CLEAR - removes all existing content.
                // RESTART - clears everything and restarts the story from the beginning
                else if( tag == "CLEAR" || tag == "RESTART" ) {
                    removeAll("p");
                    removeAll("img");
                    
                    // Comment out this line if you want to leave the header visible when clearing
                    setVisible(".header", false);

                    if( tag == "RESTART" ) {
                        restart();
                        return;
                    }else if(tag=="CLEAR"){
                        scrollToTop();
                    }
                }
            }

            // Create paragraph element (initially hidden)
            var paragraphElement = document.createElement('p');

            // CUSTOM (AVERY) - extract ((links)) from paragraph text
            var items = paragraphText.split(/(\(\(.*?\)\))/)


            // Add text & link child nodes.
            for (i in items){
                if (parseInt(i) % 2 == 0){
                    // Should not be a link 
                    paragraphElement.appendChild(document.createTextNode(items[i]));
                }else{
                    // Should be a link
                    var parsed = parse_raw_link(items[i])
                    var link_tag = document.createElement("a")
                    link_tag.innerHTML = parsed[0] // Link text
                    link_tag.id = parsed[1] // the id
                    paragraphElement.appendChild(link_tag);
                }
            }
            storyContainer.appendChild(paragraphElement);
            
            // Add any custom classes derived from ink tags
            for(var i=0; i<customClasses.length; i++)
                paragraphElement.classList.add(customClasses[i]);

            // Fade in paragraph after a short delay
            showAfter(delay, paragraphElement);
            delay += 200.0;
        }

        // Create HTML choices from ink choices
        story.currentChoices.forEach(function(choice) {
            // CUSTOM (AVERY): First, check for ((inline options))
            var override_link_element = null;
            var parsed = parse_raw_link(choice.text);
            if (parsed){
                override_link_element = document.getElementById(parsed[1]);
            }

            var choiceAnchorEl = null;
            if (!override_link_element){
                // Create paragraph with anchor element
                var choiceParagraphElement = document.createElement('p');
                choiceParagraphElement.classList.add("choice");

                // Note (AVERY): No href = no visible link at bottom of browser
                //  (I also set cursor:pointer in css)
                choiceParagraphElement.innerHTML = `<a>${choice.text}</a>`
                storyContainer.appendChild(choiceParagraphElement);

                // Fade choice in after a short delay
                showAfter(delay, choiceParagraphElement);
                delay += 200.0;

                // Click on choice
                choiceAnchorEl = choiceParagraphElement.querySelectorAll("a")[0];
            }else{
                choiceAnchorEl = override_link_element;
            }
            choiceAnchorEl.addEventListener("click", function(event) {

                // Don't follow <a> link
                event.preventDefault();

                // Remove all existing choices
                removeAll("p.choice");

                // Tell the story where to go next
                story.ChooseChoiceIndex(choice.index);

                // Aaand loop
                continueStory();
            });
        });

        // Extend height to fit
        // We do this manually so that removing elements and creating new ones doesn't
        // cause the height (and therefore scroll) to jump backwards temporarily.
        //storyContainer.style.height = contentBottomEdgeY()+"px";
        
        /*
        if( !firstTime )
            //scrollDown(previousBottomEdge);
            newScrollDown();
        */
    }

    function restart() {
        story.ResetState();

        setVisible(".header", true);
    
        // Reset map background
        setMapImage("kneiphof.png")
        // Re-hide all bridges
        for (x of "abcdefg"){
            var bridge = document.getElementById(`bridge_${x}`);
            bridge.style.visibility = "hidden";
        }

        continueStory(true);

        //outerScrollContainer.scrollTo(0, 0);
        scrollToTop();
    }

    // -----------------------------------
    // Various Helper functions
    // -----------------------------------

    // Fades in an element after a specified delay
    function showAfter(delay, el) {
        el.classList.add("hide");
        setTimeout(function() { el.classList.remove("hide") }, delay);
    }

    // Scrolls the page down, but no further than the bottom edge of what you could
    // see previously, so it doesn't go too far.
    // NOTE (AVERY): CURRENTLY NOT IN USE, I'M REPLACING THIS
    function scrollDown(previousBottomEdge) {

        // Line up top of screen with the bottom of where the previous content ended
        var target = previousBottomEdge;
        
        // Can't go further than the very bottom of the page
        var limit = outerScrollContainer.scrollHeight - outerScrollContainer.clientHeight;
        if( target > limit ) target = limit;

        var start = outerScrollContainer.scrollTop;

        var dist = target - start;
        var duration = 300 + 300*dist/100;
        var startTime = null;
        function step(time) {
            if( startTime == null ) startTime = time;
            var t = (time-startTime) / duration;
            var lerp = 3*t*t - 2*t*t*t; // ease in/out
            outerScrollContainer.scrollTo(0, (1.0-lerp)*start + lerp*target);
            if( t < 1 ) requestAnimationFrame(step);
        }
        requestAnimationFrame(step);
    }

    function newScrollDown(){
        // Scroll the main story container down.
        // TODO: smarter scrolling behaviour, 
        //  mimicking the "classic" page-wide behaviour.
        var storyDiv = document.getElementById("story");

        var start = storyDiv.scrollTop;
        var target = storyDiv.scrollHeight;
        var dist = target - start;
        var duration = 300 + 300*dist/100;
        var startTime = null;

        function step(time) {
            if( startTime == null ) startTime = time;
            var t = (time-startTime) / duration;
            var lerp = 3*t*t - 2*t*t*t; // ease in/out
            storyDiv.scrollTo(0, (1.0-lerp)*start + lerp*target);
            if( t < 1 ) requestAnimationFrame(step);
        }
        requestAnimationFrame(step);
    }

    // Scroll the story back to the top.
    function scrollToTop(){
        var storyDiv = document.getElementById("story");
        storyDiv.scrollTo(0,0)
    }

    // The Y coordinate of the bottom end of all the story content, used
    // for growing the container, and deciding how far to scroll.
    function contentBottomEdgeY() {
        var bottomElement = storyContainer.lastElementChild;
        return bottomElement ? bottomElement.offsetTop + bottomElement.offsetHeight : 0;
    }

    // Remove all elements that match the given selector. Used for removing choices after
    // you've picked one, as well as for the CLEAR and RESTART tags.
    function removeAll(selector)
    {
        var allElements = storyContainer.querySelectorAll(selector);
        for(var i=0; i<allElements.length; i++) {
            var el = allElements[i];
            el.parentNode.removeChild(el);
        }
    }

    // Used for hiding and showing the header when you CLEAR or RESTART the story respectively.
    function setVisible(selector, visible)
    {
        var allElements = storyContainer.querySelectorAll(selector);
        for(var i=0; i<allElements.length; i++) {
            var el = allElements[i];
            if( !visible )
                el.classList.add("invisible");
            else
                el.classList.remove("invisible");
        }
    }

    // Helper for parsing out tags of the form:
    //  # PROPERTY: value
    // e.g. IMAGE: source path
    function splitPropertyTag(tag) {
        var propertySplitIdx = tag.indexOf(":");
        if( propertySplitIdx != null ) {
            var property = tag.substr(0, propertySplitIdx).trim();
            var val = tag.substr(propertySplitIdx+1).trim(); 
            return {
                property: property,
                val: val
            };
        }

        return null;
    }

    // Set the bg image for the main map
    function setMapImage(image_name){
        var map = document.getElementById("map");
        map.style.backgroundImage = `url('images/${image_name}')`;
    }

    function showBridge(bridge_id){
        var bridge = document.getElementById(bridge_id);
        bridge.style.visibility = "visible";
    }

    function parse_raw_link(raw_link){
        // Given raw link (i.e. in ((bracketed form)) ),
        //  return the display text and formatted id
        var m = raw_link.trim().match(/\(\((.*)\)\)/);
        if (m){
            var link_text = m[1];
            var id_string = "op-" + link_text.replaceAll(/[^A-Za-z]/g,"-");
            return [link_text, id_string];
        }else{
            return null;
        }
    }

})(storyContent);
