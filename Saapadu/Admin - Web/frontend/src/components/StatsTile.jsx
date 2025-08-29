import {useEffect, useState} from "react";
import axios from "axios";
import "./StatsTile.css";

export const StatsTile = ({
                              name = "",
                          }) => {
    const [college, setCollege] = useState(null);
    const [data, setData] = useState(null);

    useEffect(() => {
        try {
            const savedCollege = JSON.parse(localStorage.getItem("college"));
            setCollege(savedCollege);
        } catch {
            setCollege(null);
        }
    }, []);

    useEffect(() => {
        const fetchData = async () => {

            if (!college?.id) return;

            let API_BASE;
            if (name === "Total Orders") {
                API_BASE = `http://${window.location.hostname}:8080/home/total-orders`;
            } else if (name === "Pending Orders") {
                API_BASE = `http://${window.location.hostname}:8080/home/pending-orders`;
            } else if (name === "Completed Orders") {
                API_BASE = `http://${window.location.hostname}:8080/home/completed-orders`;
            } else if(name === "Total Revenue"){
                API_BASE = `http://${window.location.hostname}:8080/home/total-revenue`;
            }
            try {
                const res = await axios.get(API_BASE, {
                    params: {collegeId: college.id}
                });
                // If the request is successful, axios will resolve and we can set the data.
                setData(res.data);
            } catch (error) {
                // If the server returns an error (4xx, 5xx), axios will reject the promise.
                console.error(`Failed to fetch ${name}:`, error);
                setData("Error");
            }
        };
        fetchData();
    }, [college, name]);

    return (
        <div className="notification">
            <div className="notiglow"/>
            <div className="notiborderglow"/>
            <div className="notititle">{name}</div>
            <div className="notibody">{name === "Total Revenue" ? `₹ ${data}` : `${data}`}</div>
        </div>
    );
}