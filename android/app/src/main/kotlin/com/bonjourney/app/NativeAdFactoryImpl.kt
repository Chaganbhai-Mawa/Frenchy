package com.bonjourney.app

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.NativeAdFactory

/** Inflates and binds the "sponsored" card shown in the Learn tab's lesson list. */
class NativeAdFactoryImpl(private val context: Context) : NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?,
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_card, null) as NativeAdView

        val headline = adView.findViewById<TextView>(R.id.ad_headline)
        val body = adView.findViewById<TextView>(R.id.ad_body)
        val icon = adView.findViewById<ImageView>(R.id.ad_app_icon)
        val cta = adView.findViewById<Button>(R.id.ad_call_to_action)

        headline.text = nativeAd.headline
        adView.headlineView = headline

        val bodyText = nativeAd.body
        if (bodyText.isNullOrEmpty()) {
            body.visibility = View.GONE
        } else {
            body.text = bodyText
            body.visibility = View.VISIBLE
        }
        adView.bodyView = body

        val ctaText = nativeAd.callToAction
        if (ctaText.isNullOrEmpty()) {
            cta.visibility = View.GONE
        } else {
            cta.text = ctaText
            cta.visibility = View.VISIBLE
        }
        adView.callToActionView = cta

        val iconAsset = nativeAd.icon
        if (iconAsset == null) {
            icon.visibility = View.GONE
        } else {
            icon.setImageDrawable(iconAsset.drawable)
            icon.visibility = View.VISIBLE
        }
        adView.iconView = icon

        adView.setNativeAd(nativeAd)
        return adView
    }
}
