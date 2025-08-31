import './App.css';
import 'bootstrap/dist/css/bootstrap.min.css';

import {BrowserRouter, Route, Routes, Navigate, useLocation} from 'react-router-dom';
import Navbar from "./components/Navbar";
import {HomePage} from "./components/HomePage";
import {SignUpPage} from "./components/SignUpPage";
import {SignInPage} from "./components/SignInPage";


// import {SignUpPage} from './components/SignUpPage';
// import {SignInPage} from "./components/SignInPage";
// import {HomePage} from "./components/HomePage";
// import {CreateShopPage} from "./components/CreateShopPage";
import {ShopPage} from "./components/ShopPage";
import {CategoryPage} from "./components/CategoryPage";
import {ItemPage} from "./components/ItemPage";
// import {CreateTile} from "./components/CreateTile";
// import {CategoryPage} from "./components/CategoryPage";
// import {ItemPage} from "./components/ItemPage";
// import Navbar from "./components/Navbar";

function Layout({children}) {
    const location = useLocation();
    const hideNavbar = ["/signIn", "/signUp"].includes(location.pathname);
    
    return(
        <>
            {!hideNavbar && <Navbar/>}
            <div>
                {children}
            </div>
        </>
    );
}

function getInitialRoute() {
    const college = JSON.parse(localStorage.getItem("college"));
    return college ? "/home" : "/signIn";
}

function App() {
    return (
        <div className="App">
            <BrowserRouter>
                <Layout>
                    <Routes>
                        <Route path="/" element={<Navigate to={getInitialRoute()} replace/>}/>
                        <Route path="/signUp" element={<SignUpPage/>}/>
                        <Route path="/signIn" element={<SignInPage/>}/>
                        <Route path="/shops" element={<ShopPage/>}/>
                        {/*<Route path="/shopList/createShop" element={<CreateShopPage/>}/>*/}
                        <Route path="/categories" element={<CategoryPage/>}/>
                        <Route path="/items" element={<ItemPage/>}/>
                        <Route path="/home" element={<HomePage/>}/>
                        <Route path="*" element={<Navigate to="/signUp" replace/>}/>
                    </Routes>
                </Layout>
            </BrowserRouter>
        </div>
    );
}

export default App;
