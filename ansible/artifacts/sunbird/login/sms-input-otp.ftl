<#import "template.ftl" as layout>
    <@layout.registrationLayout; section>
    <#if section = "title">
        ${msg("loginTitle",realm.displayName)}
    <#elseif section = "form">
    <div class="custom-wrapper">
        <div class="ui raised shadow container segment fullpage-background-image">
            <div class="ui one column grid stackable">
                <div class="ui column height-fix">
                    <div class="max-container">
                        <div class="ui header centered">
                            <img onerror="" alt="">
                            <#--  <div class="signInHead mt-27">${msg("emailForgotTitle")}</div>  -->
                        </div>
                        <div class="signInHead mt-27">
                            ${msg("enterCode")}
                        </div>
                        <div class="ui content textCenter mt-8 mb-28">
                            <#if message?has_content>
                            <div class="ui text ${message.type}" id="errorMsgMainBox">
                                ${message.summary}
                            </div>
				<span id="attempCount" class="ui text error"></span>
                            </#if>
                        </div>
                        <form id="kc-totp-login-form" class="${properties.kcFormClass!} ui form pre-signin" action="${url.loginAction}" method="post">
			                <input type="hidden" name="page_type" value="sms_otp_page" />
                            <div class="field">
                                <input id="totp" name="smsCode" type="text" class=" smsinput" onfocusin="inputBoxFocusIn(this)" onfocusout="inputBoxFocusOut(this)" onkeyup="validateOtpChar()/>
				 <span id="otpLengthErr" class="ui text error"></span>
                                 <span id="js-timeout-box" class="ui text error"></span>
                            </div>
                            <div class="field">
                                <button onclick="javascript:makeDivUnclickable()" class="ui fluid submit button" name="login" id="login" type="submit" value="${msg("doLogIn")}">${msg("doSubmit")}</button>
                            </div>
                            <div class="field or-container">
                                <div class="or-holder">
                                    <span class="or-divider"></span>
                                    <span class="or-text">or</span>
                                </div>
                            </div>
                            <div class="field"></div>
                        </form>
                        <form id="kc-totp-login-form" class="${properties.kcFormClass!} ui form pre-signin" action="${url.loginAction}" method="post">
			                <input type="hidden" name="page_type" value="sms_otp_resend_page" />
                            <div class="field">
                                <div class="ui text textCenter" id="timer-container">
                                    <span>Resend OTP after </span><span id="js-timeout"></span>
                                </div>
                                <button onclick="javascript:makeDivUnclickable(); javascript:otpLoginUser()" class="ui fluid submit button mt-8" 
                                name="resendOTP" id="resendOTP" type="submit" value="${msg("doLogIn")}" disabled>
                                    ${msg("doResendOTP")}
                                </button>
                            </div>
                        </form>
                        <#if client?? && client.baseUrl?has_content>
                            <div class="${properties.kcFormOptionsWrapperClass!} signUpMsg mb-56 mt-45 textCenter">
                                <span>
                                    <a id="backToApplication" onclick="javascript:makeDivUnclickable()" class="backToLogin" href="${client.baseUrl}">
                                        <span class="fs-14"><< </span>${msg("backToApplication")}
                                    </a>
                                </span>
                            </div>
                        </#if>
                    </div>
                </div>
                <div class="ui column tablet only computer only"></div>
            </div>
        </div>
    </div>
    </#if>
    <script>
	
        var interval
        function countdown() {
            document.getElementById("js-timeout").innerHTML = "3:00";
        // Update the count down every 1 second
        interval = setInterval( function() {
            var timer = document.getElementById("js-timeout").innerHTML;
            timer = timer.split(':');
            var minutes = timer[0];
            var seconds = timer[1];
            seconds -= 1;
            if (minutes < 0) return;
            else if (seconds < 0 && minutes != 0) {
                minutes -= 1;
                seconds = 59;
            }
            else if (seconds < 10 && length.seconds != 2) seconds = '0' + seconds;

             document.getElementById("js-timeout").innerHTML = minutes + ':' + seconds;

            if (minutes == 0 && seconds == 0) {
              clearInterval(interval);
              document.getElementById("resendOTP").removeAttribute('disabled')
              document.getElementById("timer-container").setAttribute("hidden", true);
            }
        }, 1000);
      }

 	function validateOtpChar() {
	        let userOptVal = document.getElementById("totp").value.trim()
	        if (userOptVal && userOptVal.length !== 6) {
	            document.getElementById("otpLengthErr").innerHTML = "OPT should have 6 digits"
	        } else if (userOptVal && userOptVal.length === 6) {
	            document.getElementById("otpLengthErr").innerHTML = ""
	        }
	      }

function convertStoMs(seconds) {
         let minutes = Math.floor(seconds / 60);
         let extraSeconds = seconds % 60;
         minutes = minutes < 10 ? "0" + minutes : minutes;
         extraSeconds = extraSeconds< 10 ? "0" + extraSeconds : extraSeconds;
         return minutes + " : " + extraSeconds;
      } 

function timerCount() {
  var timeInterval = setInterval(function () {
    if (sessionStorage.getItem("timeLeftForUnblock")) {
      timeLeftForUnblock = sessionStorage.getItem("timeLeftForUnblock")

    } else {
      sessionStorage.setItem("timeLeftForUnblock", timeLeftForUnblock)
    }
    timeLeftForUnblock = timeLeftForUnblock - 1
    sessionStorage.setItem("timeLeftForUnblock", timeLeftForUnblock)
    timeLeftForUnblock = parseInt(sessionStorage.getItem("timeLeftForUnblock"), 10)
    document.getElementById("js-timeout-box").innerHTML = "You will be unblock after " + convertStoMs(parseInt(timeLeftForUnblock), 10) + " minutes" 
    if (timeLeftForUnblock == 0) {
      clearInterval(timeInterval)
      sessionStorage.removeItem("loginAttempts")
      sessionStorage.removeItem("timeLeftForUnblock")
      enableFields()
      loginAttempts = 0
      timeLeftForUnblock = 900
    }
  }, 1000);
}

 var timeLeftForUnblock = 900
  var loginAttempts = Number(0) 
  var totalLoginAttempts = Number(3)

function otpLoginUser() {
document.getElementById("attempCount").style.display = "none"
    var loginCount = parseInt(sessionStorage.getItem("loginAttempts"), 10)
    if (!loginCount || loginCount === null || loginCount < totalLoginAttempts) {
      loginAttempts += 1
      sessionStorage.setItem("loginAttempts", loginAttempts)
      loginCount = parseInt(sessionStorage.getItem("loginAttempts"), 10)
      var pendingLoginAttempt = totalLoginAttempts - loginAttempts
      document.getElementById("attempCount").style.display = "block"
      document.getElementById("attempCount").innerHTML = "You have " + pendingLoginAttempt + " more attempts"
      if(pendingLoginAttempt == 0) {
         document.getElementById("attempCount").style.display = "none"
        document.getElementById("attempCount").innerHTML = ""
      }
      enableFields()
      countdown()
      document.getElementById("timer-container").setAttribute("hidden", false);
    }

    if (loginCount && loginCount == totalLoginAttempts) {
      disableFields()
      timerCount()
      document.getElementById("timer-container").setAttribute("hidden", true); 
      document.getElementById("errorMsgMainBox").setAttribute("hidden", true); 
    }
  }

  function disableFields() {
    document.getElementById("totp").disabled = true
    document.getElementById("login").disabled = true
    document.getElementById("resendOTP").disabled = true
  }

  function enableFields() {
    document.getElementById("totp").disabled = false
    document.getElementById("login").disabled = false
    document.getElementById("resendOTP").disabled = false
  }

 function onStart() {
    if (parseInt(sessionStorage.getItem("loginAttempts"), 10)) {
      loginAttempts = parseInt(sessionStorage.getItem("loginAttempts"), 10)
var LoginAttemptPending = totalLoginAttempts - loginAttempts
      document.getElementById("attempCount").style.display = "block"
      document.getElementById("attempCount").innerHTML = "You have " + LoginAttemptPending + " more attempts"
    }
    if (sessionStorage.getItem("timeLeftForUnblock",)) {
      timeLeftForUnblock = parseInt(sessionStorage.getItem("timeLeftForUnblock"), 10)
    }
    if ((loginAttempts == totalLoginAttempts) && timeLeftForUnblock != 0) {
      disableFields()
      timerCount()
     document.getElementById("attempCount").innerHTML = ""
    }
    if ((loginAttempts == totalLoginAttempts) && timeLeftForUnblock == 0) {
      enableFields()
      sessionStorage.removeItem("loginAttempts")
document.getElementById("attempCount").innerHTML = ""
      sessionStorage.removeItem("timeLeftForUnblock")
      clearInterval(timeInterval)
    }
  }
  onStart()
    </script>
</@layout.registrationLayout>