import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import requests
import os
from datetime import datetime

# Configuration
BACKEND_URL = os.getenv('BACKEND_URL', 'http://localhost:8000')
MLFLOW_URL = os.getenv('MLFLOW_TRACKING_URI', 'http://localhost:5000')

st.set_page_config(
    page_title="Hackathon Demo Dashboard",
    page_icon="🚀",
    layout="wide"
)

st.title("🚀 Hackathon Demo Dashboard")
st.markdown("**Schnell. Einfach. Beeindruckend.**")

# Sidebar
with st.sidebar:
    st.header("Navigation")
    page = st.selectbox(
        "Wähle eine Demo:",
        ["📊 Data Analytics", "🤖 ML Predictions", "📈 MLflow Integration", "🔌 API Testing"]
    )

# Page: Data Analytics
if page == "📊 Data Analytics":
    st.header("📊 Datenanalyse Demo")
    
    # Generate sample data
    if st.button("🎲 Zufällige Daten generieren"):
        data = pd.DataFrame({
            'timestamp': pd.date_range('2024-01-01', periods=100, freq='D'),
            'value': np.random.randn(100).cumsum() + 100,
            'category': np.random.choice(['A', 'B', 'C'], 100),
            'metric': np.random.uniform(0, 1, 100)
        })
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.subheader("Zeitreihen-Analyse")
            fig = px.line(data, x='timestamp', y='value', color='category')
            st.plotly_chart(fig, use_container_width=True)
        
        with col2:
            st.subheader("Kategorien-Verteilung")
            fig = px.pie(data, names='category', title="Verteilung nach Kategorien")
            st.plotly_chart(fig, use_container_width=True)
        
        st.subheader("Rohdaten")
        st.dataframe(data.head(10))

# Page: ML Predictions
elif page == "🤖 ML Predictions":
    st.header("🤖 Machine Learning Demo")
    
    st.subheader("Einfache Vorhersage")
    
    col1, col2 = st.columns(2)
    
    with col1:
        feature1 = st.slider("Feature 1", -10.0, 10.0, 0.0)
        feature2 = st.slider("Feature 2", -10.0, 10.0, 0.0)
        feature3 = st.slider("Feature 3", -10.0, 10.0, 0.0)
    
    with col2:
        if st.button("🔮 Vorhersage treffen"):
            # Simulate ML prediction
            prediction = feature1 * 0.5 + feature2 * 0.3 + feature3 * 0.2 + np.random.normal(0, 0.1)
            confidence = min(abs(prediction) * 10 + 50, 95)
            
            st.metric("Vorhersage", f"{prediction:.2f}")
            st.metric("Konfidenz", f"{confidence:.1f}%")
            
            # Visualization
            features = pd.DataFrame({
                'Feature': ['Feature 1', 'Feature 2', 'Feature 3'],
                'Wert': [feature1, feature2, feature3]
            })
            
            fig = px.bar(features, x='Feature', y='Wert', 
                        title="Feature-Werte für Vorhersage")
            st.plotly_chart(fig, use_container_width=True)

# Page: MLflow Integration
elif page == "📈 MLflow Integration":
    st.header("📈 MLflow Integration")
    
    st.info(f"MLflow UI: {MLFLOW_URL}")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Experiment simulieren")
        
        experiment_name = st.text_input("Experiment Name", "hackathon_demo")
        learning_rate = st.slider("Learning Rate", 0.001, 0.1, 0.01)
        epochs = st.slider("Epochs", 10, 100, 50)
        
        if st.button("🧪 Experiment starten"):
            # Simulate experiment metrics
            accuracy = np.random.uniform(0.8, 0.95)
            loss = np.random.uniform(0.1, 0.5)
            
            st.success("Experiment abgeschlossen!")
            st.metric("Accuracy", f"{accuracy:.3f}")
            st.metric("Loss", f"{loss:.3f}")
            
            # Show experiment info
            st.json({
                "experiment_name": experiment_name,
                "parameters": {
                    "learning_rate": learning_rate,
                    "epochs": epochs
                },
                "metrics": {
                    "accuracy": round(accuracy, 3),
                    "loss": round(loss, 3)
                },
                "timestamp": datetime.now().isoformat()
            })
    
    with col2:
        st.subheader("Model Performance")
        
        # Generate training curve
        x = np.arange(1, epochs + 1)
        train_acc = 0.5 + 0.4 * (1 - np.exp(-x/20)) + np.random.normal(0, 0.02, len(x))
        val_acc = 0.5 + 0.35 * (1 - np.exp(-x/20)) + np.random.normal(0, 0.03, len(x))
        
        df = pd.DataFrame({
            'epoch': np.concatenate([x, x]),
            'accuracy': np.concatenate([train_acc, val_acc]),
            'type': ['train'] * len(x) + ['validation'] * len(x)
        })
        
        fig = px.line(df, x='epoch', y='accuracy', color='type',
                     title="Training vs Validation Accuracy")
        st.plotly_chart(fig, use_container_width=True)

# Page: API Testing
elif page == "🔌 API Testing":
    st.header("🔌 API Integration Demo")
    
    st.info(f"Backend API: {BACKEND_URL}")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("API Health Check")
        
        if st.button("🏥 Health Check"):
            try:
                response = requests.get(f"{BACKEND_URL}/health", timeout=5)
                if response.status_code == 200:
                    st.success("✅ API ist erreichbar!")
                    st.json(response.json() if response.headers.get('content-type') == 'application/json' else {"status": "ok"})
                else:
                    st.error(f"❌ API Error: {response.status_code}")
            except requests.exceptions.RequestException as e:
                st.error(f"❌ Verbindungsfehler: {str(e)}")
                st.info("💡 Tipp: Starte den Backend-Service mit `./setup.sh demo`")
    
    with col2:
        st.subheader("Daten an API senden")
        
        sample_data = st.text_area(
            "JSON Daten:",
            '{"message": "Hello from Streamlit!", "timestamp": "' + datetime.now().isoformat() + '"}'
        )
        
        if st.button("📤 Daten senden"):
            try:
                response = requests.post(
                    f"{BACKEND_URL}/api/data",
                    json=eval(sample_data),
                    timeout=5
                )
                if response.status_code == 200:
                    st.success("✅ Daten erfolgreich gesendet!")
                    st.json(response.json())
                else:
                    st.error(f"❌ API Error: {response.status_code}")
            except Exception as e:
                st.error(f"❌ Fehler: {str(e)}")
                st.info("💡 Tipp: Überprüfe das JSON Format und die API-Verfügbarkeit")

# Footer
st.markdown("---")
st.markdown("**🏆 Hackathon Demo Stack** | Powered by Docker + Streamlit + MLflow + FastAPI")