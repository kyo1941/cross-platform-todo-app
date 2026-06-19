package com.example.crosstodo.allkotlin

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier

/**
 * Application root composable. Navigation between the list and edit screens is
 * wired up in a later step; for now it renders a placeholder.
 */
@Composable
fun TodoApp() {
    Text(
        text = "TODO",
        modifier = Modifier
            .fillMaxSize()
            .wrapContentSize(Alignment.Center),
    )
}
